{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.determinate.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../modules/nixos/caddy.nix
    ../../modules/nixos/uptermd.nix
    ../../modules/nixos/freshrss.nix
    ../../modules/nixos/rsshub.nix
    ../../modules/nixos/ntfy.nix
  ];

  sops.defaultSopsFile = ../../secrets/cosmic-crisp.yaml;

  networking.hostName = "cosmic-crisp";

  boot.loader.grub.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  services.openssh.settings.KbdInteractiveAuthentication = false;

  users.mutableUsers = false;
  sops.secrets.root-password.neededForUsers = true;
  users.users.root.hashedPasswordFile = config.sops.secrets.root-password.path;

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

  boot.zswap = {
    enable = true;
    compressor = "zstd";
  };
}
