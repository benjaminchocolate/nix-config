{
  flake.modules.nixos.mcp-nixos =
    { pkgs, ... }:
    {
      systemd.services.mcp-nixos = {
        description = "mcp-nixos MCP server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        environment = {
          MCP_NIXOS_HOST = "127.0.0.1";
          MCP_NIXOS_PORT = "8000";
          MCP_NIXOS_STATELESS_HTTP = "1";
          MCP_NIXOS_TRANSPORT = "http";
          XDG_CACHE_HOME = "/var/cache/mcp-nixos";
        };
        serviceConfig = {
          CacheDirectory = "mcp-nixos";
          DynamicUser = true;
          ExecStart = "${pkgs.mcp-nixos}/bin/mcp-nixos";
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          Restart = "on-failure";
        };
      };

      services.caddy.virtualHosts."mcp-nixos.carpenterlab.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:8000
      '';
    };
}
