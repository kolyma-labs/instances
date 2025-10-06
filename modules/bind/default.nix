{
  config,
  lib,
  ...
}: let
  generateZone = zone: type: let
    master = type == "master";
    file = "/var/dns/${zone}.zone";
  in
    if master
    then {
      inherit master file;
      inherit (config.kolyma.nameserver) slaves;
      extraConfig = ''
        ${lib.optionalString (config.kolyma.nameserver.slaves != []) ''
          notify yes;
          also-notify { ${lib.concatStringsSep "; " config.kolyma.nameserver.slaves}; };
          allow-update { ${lib.concatStringsSep "; " config.kolyma.nameserver.slaves}; localhost; };
          update-policy {
            grant retard. name _acme-challenge.${zone}. txt;
          };
        ''}
      '';
    }
    else {
      inherit master file;
      inherit (config.kolyma.nameserver) masters;
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
    lib.mkIf (config.kolyma.nameserver.type == "master")
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

  cfg = {
    services.bind = {
      inherit (config.kolyma.nameserver) enable;
      directory = "/var/bind";
      zones = zonesMap config.kolyma.nameserver.zones config.kolyma.nameserver.type;
      extraConfig = ''
        ${config.kolyma.nameserver.extra}

        key "retard." {
          algorithm hmac-sha256;
          secret "2hTccy12ZpUfr3bJfqdjwe0AiMLvCOOT3jHJR6OmI94=";
        };
      '';
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
    kolyma.nameserver = {
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
        default = [
          # Kolyma GK-1
          "37.27.67.190"
          "2a01:4f9:3081:3518::2"
        ];
        description = "IP address of the master server.";
      };

      slaves = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          # Kolyma GK-2
          "37.27.60.37"
          "2a01:4f9:3081:2e04::2"

          # Kolyma GK-3
          "65.21.83.85"
          "2a01:4f9:3080:2c81::2"

          # Kolyma GK-4
          "65.109.103.11"
          "2a01:4f9:3080:2829::2"

          # Kolyma GK-5
          "167.235.96.40"
          "2a01:4f8:2190:2914::2"

          # Kolyma GK-6
          "65.109.74.214"
          "2a01:4f9:3071:31ce::2"
        ];
        description = "List of slave servers.";
      };

      zones = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default =
          builtins.readDir ../../data/zones
          |> lib.attrsets.filterAttrs (n: v: v == "regular")
          |> lib.attrsets.mapAttrsToList (n: _: n)
          |> builtins.map (f: lib.strings.removeSuffix ".zone" f);
        description = "List of zones to be served.";
      };

      extra = lib.mkOption {
        type = lib.types.lines;
        description = "Extra zone config to be appended at the end of the zone section.";
        default = "";
      };
    };
  };

  config =
    lib.mkMerge [cfg zoneFiles]
    |> lib.mkIf config.kolyma.nameserver.enable;

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
