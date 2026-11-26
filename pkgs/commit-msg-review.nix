# commit-msg hook: Apple's on-device model (fm, macOS 27+) checks the message
# against a spec and asks before replacing it. A repo can replace the default
# spec with a .commit-rules file. Skips itself with no terminal, no fm (Linux,
# older macOS), or a merge/fixup/squash message.
# Skip on purpose: SKIP=commit-msg-review git commit
{
  writeShellApplication,
  writeText,
  git,
}:
let
  defaultRules = writeText "commit-msg-rules.txt" ''
    Commit message spec (Chris Beams, "How to Write a Git Commit Message"):
    - Subject: imperative mood ("Add", "Fix", "Replace"), capitalized,
      no trailing period, at most 50 characters.
    - The subject completes "If applied, this commit will ...".
    - Name what changed (host, module, service) so the log is searchable.
    - No prefixes like "feat:" or "fix:".
    - Default to a subject only. Add a body only when the diff can't show
      why the change was made. A body is at most 3 lines and explains why,
      not how.

    Examples:

    Replace Vim with Neovim on both hosts

    Move CLI tools from Homebrew to Nix

    Override brew-src for nix-homebrew

    Its pinned brew was older than homebrew-core, so formulae
    became unreadable.
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

    # A repo's own spec replaces the default; two specs at once confuse a small model
    rules_file="$(git rev-parse --show-toplevel)/.commit-rules"
    [ -f "$rules_file" ] || rules_file=${defaultRules}

    printf 'Reviewing commit message...\n' >/dev/tty

    suggestion=$(
      {
        printf 'Recent commit subjects in this repo (match their style):\n'
        git log -10 --format=%s 2>/dev/null || true
        printf '\nCurrent message:\n%s\n\nStaged changes:\n' "$original"
        git diff --cached --stat
        git diff --cached | head -c 6000 || true # the on-device model has a small context
      } | fm respond -g -i "$(cat "$rules_file")

    Reply with only the commit message: no commentary, no code fences.
    If the current message already follows the spec, reply with it unchanged."
    ) || {
      printf 'fm failed, keeping your message. First time? Run: sudo fm license\n' >/dev/tty
      exit 0
    }

    # Enforce the hard limits here instead of trusting the model
    suggestion=$(printf '%s\n' "$suggestion" | sed '/^```/d' | git stripspace)
    subject=$(printf '%s\n' "$suggestion" | head -n 1)
    body=$(printf '%s\n' "$suggestion" | tail -n +2 | git stripspace)
    if [ "''${#subject}" -gt 50 ]; then exit 0; fi
    if [ "$(printf '%s' "$body" | grep -c . || true)" -gt 3 ]; then body=""; fi
    if [ -n "$body" ]; then
      suggestion=$(printf '%s\n\n%s\n' "$subject" "$(printf '%s\n' "$body" | fold -s -w 72 | sed 's/ *$//')")
    else
      suggestion=$subject
    fi

    if [ "$suggestion" = "$original" ]; then exit 0; fi

    printf '\nYours:\n\n%s\n\nSuggested:\n\n%s\n\n' "$original" "$suggestion" >/dev/tty
    printf 'Use suggestion? [y]es / [n]o, keep mine / [a]bort commit: ' >/dev/tty
    read -r answer </dev/tty || answer=n

    case "$answer" in
      y | Y) printf '%s\n' "$suggestion" >"$msg_file" ;;
      a | A) exit 1 ;;
    esac
  '';
}
