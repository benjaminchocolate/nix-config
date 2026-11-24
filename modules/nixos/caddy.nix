{
  services.caddy = {
    enable = true;
    virtualHosts."carpenterlab.dev".extraConfig = ''
      respond "carpenterlab.dev"
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
