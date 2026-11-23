{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.uptermd.enable = true;
  services.uptermd.openFirewall = true;
}
