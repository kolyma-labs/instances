{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.network;

  gateway = ip: let
    parts = lib.splitString "." ip;
  in
    lib.concatStringsSep "." (lib.take 3 parts ++ ["1"]);

  ipv4 = lib.mkIf cfg.ipv4.enable {
    networking = {
      interfaces = {
        "${cfg.interface}" = {
          ipv4.addresses = [
            {
              inherit (cfg.ipv4) address;
              prefixLength = 24;
            }
          ];
        };
      };

      # If you want to configure the default gateway
      defaultGateway = {
        address = gateway cfg.ipv4.address;
        interface = "${cfg.interface}";
      };
    };
  };

  ipv6 = lib.mkIf cfg.ipv6.enable {
    networking = {
      interfaces = {
        "${cfg.interface}" = {
          ipv6.addresses = [
            {
              inherit (cfg.ipv6) address;
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

  asserts = {
    assertions = [
      {
        assertion = !(cfg.ipv4.enable && cfg.ipv4.address == "");
        message = "you see to forgot to appoint an address for ipv4";
      }
      {
        assertion = !(cfg.ipv6.enable && cfg.ipv6.address == "");
        message = "you see to forgot to appoint an address for ipv6";
      }
    ];
  };
in {
  options = {
    network = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable networking configs.";
      };

      interface = lib.mkOption {
        type = lib.types.str;
        default = "eth0";
        description = "Network interface.";
      };

      ipv4.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable IPv4 networking.";
      };

      ipv4.address = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "IPv4 address.";
      };

      ipv6.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable IPv6 networking.";
      };

      ipv6.address = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "IPv6 address.";
      };

      nameserver = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        description = "DNS nameserver.";
      };
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  config = lib.mkIf cfg.enable (lib.mkMerge [
    main
    ipv4
    ipv6
    packs
    asserts
  ]);
}
