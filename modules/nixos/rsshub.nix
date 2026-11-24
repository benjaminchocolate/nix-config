{
  config,
  ...
}:
{
  services.rsshub.enable = true;
  services.rsshub.redis.enable = true;

  sops.secrets.rsshub-env.restartUnits = [ "rsshub.service" ];
  services.rsshub.secretFiles = [ config.sops.secrets.rsshub-env.path ];

  services.caddy.virtualHosts."rsshub.carpenterlab.dev".extraConfig = ''
    reverse_proxy 127.0.0.1:1200
  '';
}
