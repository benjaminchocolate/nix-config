{ ... }:
{
  services.rsshub.enable = true;
  services.rsshub.redis.enable = true;

  services.caddy.virtualHosts."rsshub.carpenterlab.dev".extraConfig = ''
    reverse_proxy 127.0.0.1:1200
  '';
}

# Later, for the migration: services.rsshub.secretFiles takes files of
# environment variables (API keys, cookies) so secrets stay out of the repo.
