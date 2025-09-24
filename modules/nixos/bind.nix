{
  config,
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
      inherit (config.services.nameserver) slaves;
      extraConfig = ''
        ${lib.optionalString (config.services.nameserver.slaves != []) ''
          notify yes;
          also-notify { ${lib.concatStringsSep "; " config.services.nameserver.slaves}; };
          allow-update { ${lib.concatStringsSep "; " config.services.nameserver.slaves}; localhost; };
        ''}
      '';
    }
    else {
      inherit master file;
      inherit (config.services.nameserver) masters;
      extraConfig = ''
        masterfile-format text;
      '';
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
    lib.mkIf (config.services.nameserver.enable && (config.services.nameserver.type == "master"))
    {
      system.activationScripts.copyZones = lib.mkForce {
        text = ''
          # Create /var/dns
          mkdir -p /var/dns

          # Copy all zone files to /var/dns
          for zoneFile in ${../../data/zones}/*.zone; do
            cp -f "$zoneFile" /var/dns/
          done

          # Give perms over everything for named
          chown -R named:named /var/dns
          chmod 750 /var/dns
          find /var/dns -type f -exec chown named:named {} \;
        '';
        deps = [];
      };
    };

  cfg = lib.mkIf config.services.nameserver.enable {
    services.bind = {
      inherit (config.services.nameserver) enable;
      directory = "/var/bind";
      zones = zonesMap config.services.nameserver.zones config.services.nameserver.type;
      extraConfig = config.services.nameserver.extra;
    };

    networking = {
      resolvconf.useLocalResolver = false;

      # DNS standard port for connections + that require more than 512 bytes
      firewall = {
        allowedUDPPorts = [53];
        allowedTCPPorts = [53];
      };
    };
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
        default = [];
        description = "IP address of the master server.";
      };

      slaves = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of slave servers.";
      };

      zones = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = zones;
        description = "List of zones to be served.";
      };

      extra = lib.mkOption {
        type = lib.types.lines;
        description = "Extra zone config to be appended at the end of the zone section.";
        default = "";
      };
    };
  };

  config = lib.mkMerge [
    cfg
    zoneFiles
  ];
}
