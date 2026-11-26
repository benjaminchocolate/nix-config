{ inputs, ... }:
{
  flake.modules.darwin.ds-store-killer = {
    imports = [ inputs.ds-store-killer.darwinModules.default ];

    services.dsk = {
      enable = true;
      paths = [ "/" ];
    };
  };
}
