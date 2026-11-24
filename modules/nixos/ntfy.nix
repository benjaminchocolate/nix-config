{ config, ... }:
{
  services.ntfy-sh = {
    enable = true;
    environmentFile = config.sops.secrets.ntfy-env.path;
    settings = {
      base-url = "https://ntfy.carpenterlab.dev";
      listen-http = "127.0.0.1:2586";
      behind-proxy = true;
      auth-default-access = "deny-all";
      upstream-base-url = "https://ntfy.sh"; # instant iOS push
    };
  };

  sops.secrets.ntfy-env.restartUnits = [ "ntfy-sh.service" ];

  services.caddy.virtualHosts."ntfy.carpenterlab.dev".extraConfig = ''
    reverse_proxy 127.0.0.1:2586
  '';
}
