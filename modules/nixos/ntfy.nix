{
  config,
  ...
}:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.carpenterlab.dev";
      listen-http = "127.0.0.1:2586";
      behind-proxy = true;
      upstream-base-url = "https://ntfy.sh";
      auth-default-access = "deny-all";
    };
    environmentFile = config.sops.secrets.ntfy-env.path;
  };

  sops.secrets.ntfy-env.restartUnits = [ "ntfy-sh.service" ];

  services.caddy.virtualHosts."ntfy.carpenterlab.dev".extraConfig = ''
    reverse_proxy 127.0.0.1:2586
  '';
}
