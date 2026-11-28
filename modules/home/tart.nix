{
  flake.modules.homeManager.tart =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      home = "${config.xdg.dataHome}/tart";
    in
    {
      home.packages = [ pkgs.tart ];
      home.sessionVariables.TART_HOME = home;

      # Keep tens of GB of VMs out of Time Machine
      home.activation.tartBackupExclusion = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "${home}"
        run /usr/bin/tmutil addexclusion "${home}"
      '';
    };
}
