{
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.copyparty.nixosModules.default ];
  nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

  sops.secrets.copyparty-ben = {
    owner = "copyparty";
    restartUnits = [ "copyparty.service" ];
  };

  sops.secrets.copyparty-friends = {
    owner = "copyparty";
    restartUnits = [ "copyparty.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/copyparty/files 0750 copyparty copyparty -"
    "d /var/lib/copyparty/shared 0750 copyparty copyparty -"
  ];

  services.copyparty = {
    enable = true;
    settings = {
      i = "127.0.0.1"; # listen only on localhost; Caddy is the front door
      p = 3923;
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

  services.caddy.virtualHosts."copyparty.carpenterlab.dev".extraConfig = ''
    reverse_proxy 127.0.0.1:3923
  '';
}
