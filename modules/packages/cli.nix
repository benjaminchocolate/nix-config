{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        applesauce
        aria2
        bashInteractive
        bat
        cheat
        eza
        fd
        navi
        ripgrep
        rsync
        tlrc
        tree
        wget
        xdg-ninja
        zoxide
      ];
    };
}
