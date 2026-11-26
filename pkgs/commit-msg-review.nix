# commit-msg hook: Apple's on-device model (fm, macOS 27+) reviews the message
# against the rules below and asks before replacing it. Skips itself with no
# terminal, no fm (Linux, older macOS), or a merge/fixup/squash message.
# Skip on purpose: SKIP=commit-msg-review git commit
{
  writeShellApplication,
  writeText,
  git,
}:
let
  rules = writeText "commit-msg-rules.txt" ''
    You review git commit messages for a personal Nix configuration repo.

    Follow these rules:
    - Subject: imperative mood ("Add", "Fix", "Set up"), capitalized,
      no trailing period, 50 characters or fewer.
    - The subject must complete the sentence "If applied, this commit will ...".
    - Name what changed (host, module, service) so the log is searchable.
    - Add a body only when the reason isn't obvious from the diff:
      blank line after the subject, wrap at 72 characters, explain why.
    - No Conventional Commits prefixes like "feat:".
    - Change only what breaks a rule. If the message follows the rules,
      return it unchanged, even if you would phrase it differently.
  '';
in
writeShellApplication {
  name = "commit-msg-review";
  runtimeInputs = [ git ];
  text = ''
    msg_file="$1"

    # No terminal to ask on, or no fm: say nothing, keep the message.
    if ! (exec </dev/tty) 2>/dev/null; then exit 0; fi
    if ! command -v fm >/dev/null; then exit 0; fi

    original=$(git stripspace --strip-comments <"$msg_file")
    case "$original" in
      "" | "Merge "* | "fixup!"* | "squash!"*) exit 0 ;;
    esac

    printf 'Reviewing commit message...\n' >/dev/tty

    suggestion=$(
      {
        printf 'Current message:\n%s\n\nStaged changes:\n' "$original"
        git diff --cached --stat
        git diff --cached | head -c 6000 || true # the on-device model has a small context
      } | fm respond -g -i "$(cat ${rules})

    Reply with only the commit message: no commentary, no code fences.
    If the current message already follows the rules, reply with it unchanged."
    ) || {
      printf 'fm failed, keeping your message. First time? Run: sudo fm license\n' >/dev/tty
      exit 0
    }

    if [ -z "$suggestion" ] || [ "$suggestion" = "$original" ]; then exit 0; fi

    printf '\nYours:\n\n%s\n\nSuggested:\n\n%s\n\n' "$original" "$suggestion" >/dev/tty
    printf 'Use suggestion? [y]es / [n]o, keep mine / [a]bort commit: ' >/dev/tty
    read -r answer </dev/tty || answer=n

    case "$answer" in
      y | Y) printf '%s\n' "$suggestion" >"$msg_file" ;;
      a | A) exit 1 ;;
    esac
  '';
}
