{
  flake.modules.nixos.uptermd = {
    services.uptermd = {
      enable = true;
      openFirewall = true;
    };
  };
}
