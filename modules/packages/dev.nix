{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        age
        gh
        gitleaks
        gnumake
        just
        mosh
        nixfmt
        rclone
        sequoia-sq
        shellcheck
        sops
        uv
        vscode-langservers-extracted
      ];
    };
}
