{ inputs, ... }:
{
  flake.modules.darwin.system =
    { config, pkgs, ... }:
    let
      home = config.users.users.${config.system.primaryUser}.home;
    in
    {
      nix.enable = false; # Determinate Nix manages the daemon

      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null; # shown by darwin-version

      security.pam.services.sudo_local.touchIdAuth = true;

      networking.applicationFirewall = {
        enable = true;
        enableStealthMode = true;
        allowSigned = false;
        allowSignedApp = false;
        blockAllIncoming = false; # must stay off, or the allowlist is ignored
      };

      environment.systemPackages = [ pkgs.nixd ];

      environment.systemPath = [
        "/opt/homebrew/bin"
        "${home}/.local/bin"
      ];
    };
}
