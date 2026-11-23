{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.determinate.nixosModules.default
    ./hardware-configuration.nix
    ./disk-config.nix
    ./services/caddy.nix
    ./services/uptermd.nix
    ./services/freshrss.nix
    #./services/rsshub.nix
  ];

  networking.hostName = "cosmic-crisp";

  boot.loader.grub.enable = true; # disko adds /dev/sda to GRUB's install targets automatically, because of the EF02 partition
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.ghostty.terminfo
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAdLYVYSaZKTxMq+Ibj4AGVq7L37QinufiiQN06KtBML dev@benjamincarpenter.dev MBP"
  ];

  system.stateVersion = "26.05";
  # home.stateVersion

  boot.initrd.systemd.enable = true;

  networking.useDHCP = false;
  systemd.network.enable = true;
  services.resolved.enable = true;
  systemd.network.networks."10-ens18" = {
    matchConfig.Name = "ens18";
    address = [
      "104.204.70.197/23"
      "2606:a8c0:8::bb/48"
    ];
    routes = [
      { Gateway = "104.204.70.1"; }
      { Gateway = "2606:a8c0:8::1"; }
    ];
    dns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}

# uptermd
#
