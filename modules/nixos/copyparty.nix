{ config, inputs, ... }:
{
  imports = [ inputs.copyparty.nixosModules.default ];
  nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

  services.copyparty = {
    enable = true;
    settings = {
      i = "127.0.0.1";
      p = 3923;
      # Trust Caddy's header so copyparty sees real client IPs.
      xff-hdr = "x-forwarded-for";
      xff-src = "127.0.0.1";
      rproxy = 1;
    };
    accounts = {
      ben.passwordFile = config.sops.secrets.copyparty-ben.path;
      friends.passwordFile = config.sops.secrets.copyparty-friends.path;
    };
    volumes = {
      "/" = {
        path = "/var/lib/copyparty/files";
        access.A = "ben";
      };
      "/shared" = {
        path = "/var/lib/copyparty/shared";
        access = {
          A = "ben";
          rw = "friends";
        };
      };
    };
  };

  # copyparty won't start if a volume's folder is missing.
  systemd.tmpfiles.rules = [
    "d /var/lib/copyparty/files 0750 copyparty copyparty -"
    "d /var/lib/copyparty/shared 0750 copyparty copyparty -"
  ];

  sops.secrets = {
    copyparty-ben = {
      owner = "copyparty";
      restartUnits = [ "copyparty.service" ];
    };
    copyparty-friends = {
      owner = "copyparty";
      restartUnits = [ "copyparty.service" ];
    };
  };

  services.caddy.virtualHosts."copyparty.carpenterlab.dev".extraConfig = ''
    reverse_proxy 127.0.0.1:3923
  '';
}
