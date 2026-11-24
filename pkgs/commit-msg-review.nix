# commit-msg hook: asks Claude to review the commit message against
# the rules below, shows the suggestion, and asks before using it.
#
# It never blocks a commit by accident. It skips itself when there is no
# terminal to ask on (GUI clients, Claude Code, CI), when the claude CLI is
# missing or fails, and for merge/fixup/squash messages.
# Skip it on purpose with: SKIP=commit-msg-review git commit ...
{
  writeShellApplication,
  writeText,
  git,
}:
let
  rules = writeText "commit-msg-rules.txt" ''
    You review git commit messages for a personal Nix configuration repo.

    TODO(ben): write the rules a good commit message follows here.
  '';
in
writeShellApplication {
  name = "commit-msg-review";
  runtimeInputs = [ git ];
  text = ''
    msg_file="$1"

    # No terminal to ask on, or no claude CLI: say nothing, keep the message.
    if ! (exec </dev/tty) 2>/dev/null; then exit 0; fi
    if ! command -v claude >/dev/null; then exit 0; fi

    original=$(git stripspace --strip-comments <"$msg_file")
    case "$original" in
      "" | "Merge "* | "fixup!"* | "squash!"*) exit 0 ;;
    esac

    printf 'Reviewing commit message...\n' >/dev/tty

    suggestion=$(
      {
        printf 'Current message:\n%s\n\nStaged changes:\n' "$original"
        git diff --cached --stat
        git diff --cached | head -c 30000 || true
      } | claude -p --model haiku "$(cat ${rules})

    Reply with only the commit message: no commentary, no code fences.
    If the current message already follows the rules, reply with it unchanged."
    ) || exit 0

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
