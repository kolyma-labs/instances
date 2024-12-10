{
  config,
  pkgs,
  lib,
  ...
}: let
  # Statically defined list of zones
  zones = ["kolyma.uz"];

  generateZone = zone: type: let
    master = type == "master";
    file = "/var/dns/${zone}.zone";
  in
    if master
    then {
      inherit master file;
      slaves = config.services.nameserver.slaves;
    }
    else {
      inherit master file;
      masters = config.services.nameserver.masters;
    };

  # Map through given array of zones and generate zone object list
  zonesMap = zones: type:
    lib.listToAttrs (
      map (zone: {
        name = zone;
        value = generateZone zone type;
      })
      zones
    );

  # If type is master, activate system.activationScripts.copyZones
  zoneFiles =
    lib.mkIf (config.services.nameserver.enable && config.services.nameserver.type == "master")
    {
      system.activationScripts.copyZones = lib.mkForce {
        text = ''
          mkdir -p /var/dns
          for zoneFile in ${../../data/zones}/*.zone; do
            cp -f "$zoneFile" /var/dns/
          done
        '';
        deps = [];
      };
    };

  cfg = lib.mkIf config.services.nameserver.enable {
    services.bind = {
      enable = config.services.nameserver.enable;
      directory = "/var/bind";
      zones = zonesMap config.services.nameserver.zones config.services.nameserver.type;
    };

    networking.resolvconf.useLocalResolver = false;

    # DNS standard port for connections + that require more than 512 bytes
    networking.firewall.allowedUDPPorts = [53];
    networking.firewall.allowedTCPPorts = [53];
  };
in {
  options = {
    services.nameserver = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the nameserver service";
      };

      type = lib.mkOption {
        type = lib.types.enum [
          "master"
          "slave"
        ];
        default = "master";
        description = "The type of the bind zone, either 'master' or 'slave'.";
      };

      masters = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["167.235.96.40"];
        description = "IP address of the master server.";
      };

      slaves = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["65.109.74.214"];
        description = "List of slave servers.";
      };

      zones = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = zones;
        description = "List of zones to be served.";
      };
    };
  };

  config = lib.mkMerge [
    cfg
    zoneFiles
  ];
}
