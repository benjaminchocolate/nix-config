{ config, ... }:
{
  services.freshrss = {
    enable = true;
    webserver = "caddy";
    virtualHost = "freshrss.carpenterlab.dev";
    baseUrl = "https://freshrss.carpenterlab.dev";
    defaultUser = "ben";
    passwordFile = config.sops.secrets.freshrss-password.path;
    api.enable = true;
  };

  sops.secrets.freshrss-password.owner = config.services.freshrss.user;
}
