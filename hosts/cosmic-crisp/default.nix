{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.determinate.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    inputs.self.modules.nixos.cosmic-crisp-disk

    ../../legacy/nixos/caddy.nix
    ../../legacy/nixos/copyparty.nix
    ../../legacy/nixos/freshrss.nix
    ../../legacy/nixos/ntfy.nix
    ../../legacy/nixos/rsshub.nix
    ../../legacy/nixos/uptermd.nix
  ];

  networking.hostName = "cosmic-crisp";
  system.stateVersion = "26.05";

  boot = {
    loader.grub.enable = true;
    initrd.systemd.enable = true;
    zswap = {
      enable = true;
      compressor = "zstd";
    };
  };

  networking.useDHCP = false;
  services.resolved.enable = true;
  systemd.network = {
    enable = true;
    networks."10-ens18" = {
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
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  sops = {
    defaultSopsFile = ../../secrets/cosmic-crisp.yaml;
    secrets.root-password.neededForUsers = true;
  };

  users = {
    # Otherwise the root password is only set when root is first created.
    mutableUsers = false;
    users.root = {
      hashedPasswordFile = config.sops.secrets.root-password.path; # console only; SSH refuses passwords
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAdLYVYSaZKTxMq+Ibj4AGVq7L37QinufiiQN06KtBML dev@benjamincarpenter.dev MBP"
      ];
    };
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.ghostty.terminfo
    pkgs.gitMinimal
  ];

  hardware.facter.reportPath = ./facter.json;
  hardware.facter.detected.graphics.enable = false;
  hardware.facter.detected.dhcp.enable = false;
}
