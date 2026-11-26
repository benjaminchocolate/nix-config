{
  flake.modules.darwin.security = {
    security.pam.services.sudo_local.touchIdAuth = true;

    networking.applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      allowSigned = false;
      allowSignedApp = false;
      blockAllIncoming = false; # must stay off, or the allowlist is ignored
    };
  };
}
