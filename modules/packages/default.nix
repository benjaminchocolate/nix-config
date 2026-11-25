{ inputs, ... }:
{
  # Honeycrisp imports only darwin.packages; this pulls in the Home Manager half.
  flake.modules.darwin.packages =
    { config, ... }:
    {
      home-manager.users.${config.system.primaryUser}.imports = [
        inputs.self.modules.homeManager.packages
      ];
    };
}
