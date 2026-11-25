{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        aria2
        bat
        cheat
        eza
        fd
        navi
        ripgrep
        tlrc
        tree
        wget
        zoxide
      ];
    };
}
