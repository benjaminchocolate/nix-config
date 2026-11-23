{ ... }:
{
  services.freshrss = {
    enable = true;
    webserver = "caddy";

    virtualHost = "freshrss.carpenterlab.dev";
    baseUrl = "https://freshrss.carpenterlab.dev";

    defaultUser = "ben";
    passwordFile = "/var/lib/secrets/freshrss-password";

    api.enable = true;
  };
}
