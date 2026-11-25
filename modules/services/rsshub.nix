{
  flake.modules.nixos.rsshub =
    { config, ... }:
    {
      services.rsshub = {
        enable = true;
        redis.enable = true;
        secretFiles = [ config.sops.secrets.rsshub-env.path ];
      };

      sops.secrets.rsshub-env.restartUnits = [ "rsshub.service" ];

      services.caddy.virtualHosts."rsshub.carpenterlab.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:1200
      '';
    };
}
