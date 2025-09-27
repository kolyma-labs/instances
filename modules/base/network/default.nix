{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.network;

  gateway = ip: let
    parts = lib.splitString "." ip;
  in
    lib.concatStringsSep "." (lib.take 3 parts ++ ["1"]);

  ipv4 = lib.mkIf (cfg.ipv4 != null) {
    networking = {
      interfaces = {
        "${cfg.interface}" = {
          ipv4.addresses = [
            {
              address = cfg.ipv4;
              prefixLength = 24;
            }
          ];
        };
      };

      # If you want to configure the default gateway
      defaultGateway = {
        address = gateway cfg.ipv4;
        interface = "${cfg.interface}";
      };
    };
  };

  ipv6 = lib.mkIf (cfg.ipv6 != null) {
    networking = {
      interfaces = {
        "${cfg.interface}" = {
          ipv6.addresses = [
            {
              address = cfg.ipv6;
              prefixLength = 64;
            }
          ];
        };
      };

      # If you want to configure the default gateway
      defaultGateway6 = {
        address = "fe80::1"; # Replace with your actual gateway for IPv6
        interface = "${cfg.interface}";
      };
    };
  };

  packs = {
    environment.systemPackages = with pkgs; [
      dig
      inetutils
    ];
  };

  main = {
    networking = {
      useDHCP = false;

      interfaces = {
        "${cfg.interface}" = {
          useDHCP = true;
        };
      };

      # DNS configuration
      nameservers = cfg.nameserver;
    };
  };

  mkWarning = msg: {
    warnings = [msg];
  };

  warnings =
    lib.mkIf
    (cfg.ipv4 == null && cfg.ipv6 == null)
    (mkWarning "are you SURE that you want to go without any public ip address?");

  asserts = {
    assertions = [
      {
        assertion = cfg.ipv4 != null;
        message = "you see to forgot to appoint an address for ipv4";
      }
      {
        assertion = cfg.ipv6 != null;
        message = "you see to forgot to appoint an address for ipv6";
      }
    ];
  };

  merge = lib.mkMerge [main ipv4 ipv6 packs asserts warnings];
in {
  options = {
    kolyma.network = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable networking configs.";
      };

      interface = lib.mkOption {
        type = lib.types.str;
        default = "eth0";
        description = "Target network interface.";
      };

      ipv4 = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "IPv4 address for target.";
      };

      ipv6 = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "IPv6 address for target.";
      };

      nameserver = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        description = "DNS nameserver for targets.";
      };
    };
  };

  config = lib.mkIf cfg.enable merge;

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
