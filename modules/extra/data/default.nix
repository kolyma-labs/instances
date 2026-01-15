{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.kolyma.data;
in
{
  options = {
    kolyma.data = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable data ownership maintainance.";
      };

      path = lib.mkOption {
        type = lib.types.str;
        default = "/srv";
        description = "Path where normally servers keep data.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "admins";
        description = "User group to which ownership over data path should be given.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = {
      name = "${cfg.group}";
    };

    system.activationScripts.chownData = {
      text = ''
        #!/bin/sh
        chown -R :${cfg.group} ${cfg.path}
        chmod -R 777 ${cfg.path}
      '';
    };

    systemd.services.chownData = {
      description = "Change ownership of ${cfg.path}";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c ${config.system.activationScripts.chownData.text}";
        RemainAfterExit = true;
      };
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [ orzklv ];
  };
}
