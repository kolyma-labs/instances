{
  pkgs,
  lib,
  config,
  ...
}: let
  gateway = ip: let
    parts = lib.splitString "." ip;
  in
    lib.concatStringsSep "." (lib.take 3 parts ++ ["1"]);

  ipv4 = lib.mkIf config.network.ipv4.enable {
    networking = {
      interfaces = {
        "${config.network.interface}" = {
          ipv4.addresses = [
            {
              inherit (config.network.ipv4) address;
              prefixLength = 24;
            }
          ];
        };
      };

      # If you want to configure the default gateway
      defaultGateway = {
        address = gateway config.network.ipv4.address;
        interface = "${config.network.interface}";
      };
    };
  };

  ipv6 = lib.mkIf config.network.ipv6.enable {
    networking = {
      interfaces = {
        "${config.network.interface}" = {
          ipv6.addresses = [
            {
              inherit (config.network.ipv6) address;
              prefixLength = 64;
            }
          ];
        };
      };

      # If you want to configure the default gateway
      defaultGateway6 = {
        address = "fe80::1"; # Replace with your actual gateway for IPv6
        interface = "${config.network.interface}";
      };
    };
  };

  packs = lib.mkIf config.network.enable {
    environment.systemPackages = with pkgs; [
      dig
      inetutils
    ];
  };

  cfg = lib.mkIf config.network.enable {
    networking = {
      useDHCP = false;

      interfaces = {
        "${config.network.interface}" = {
          useDHCP = true;
        };
      };

      # DNS configuration
      nameservers = config.network.nameserver;
    };
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
          "8.8.8.8"
          "8.8.4.4"
        ];
        description = "DNS nameserver.";
      };
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  config = lib.mkMerge [
    ipv4
    ipv6
    cfg
    packs
  ];
}
