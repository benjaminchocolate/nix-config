{ inputs, ... }:
{
  imports = [ inputs.ds-store-killer.darwinModules.default ];

  services.dsk = {
    enable = true;
    paths = [ "/" ];
    #notify = true;
  };
}
