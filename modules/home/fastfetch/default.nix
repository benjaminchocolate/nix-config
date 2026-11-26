{
  flake.modules.homeManager.fastfetch =
    { lib, ... }:
    {
      programs.fastfetch = {
        enable = true;
        settings = {
          logo = {
            type = "kitty-direct";
            source = ./logo.png; # nix-darwin logo, not 0BSD (see NOTICE)
            height = 8;
            width = 19;
          };
          modules = [
            "title"
            "separator"
            "os"
            "uptime"
            "memory"
            "disk"
            "battery"
            "localip"
          ];
        };
      };

      programs.zsh.initContent = lib.mkOrder 1500 "fastfetch";
    };

}
