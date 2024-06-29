{
  pkgs,
  lib,
  config,
  ...
}: let
  gateway = ip: let
    parts = lib.splitString "." ip;
  in lib.concatStringsSep "." (lib.take 3 parts ++ ["1"]);

  ipv4 = lib.mkIf config.networking.ipv4.enable {
    networking = {
      useDHCP = false;

      interfaces = {
        "${config.networking.interface}" = {
          useDHCP = true;

          ipv4.addresses = [
            {
              address = config.networking.ipv4.address;
              prefixLength = 24;
            }
          ];
        };
      };

      # If you want to configure the default gateway
      defaultGateway = {
        address = gateway config.networking.ipv4.address;
        interface = "${config.networking.interface}";
      };
    };
  };

  ipv6 = lib.mkIf config.networking.ipv6.enable {
    networking = {
      useDHCP = false;

      interfaces = {
        "${config.networking.interface}" = {
          useDHCP = true;

          ipv6.addresses = [
            {
              address = config.networking.ipv6.address;
              prefixLength = 64;
            }
          ];
        };
      };

      # If you want to configure the default gateway
      defaultGateway6 = {
        address = "fe80::1"; # Replace with your actual gateway for IPv6
        interface = "${config.networking.interface}";
      };
    };
  };

  cfg = lib.mkIf config.networking.enable {
    networking = {
      useDHCP = false;

      interfaces = {
        "${config.networking.interface}" = {
          useDHCP = true;
        };
      };

      # DNS configuration
      nameservers = config.networking.nameserver;
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
        type = lib.types.str;
        default = "";
        description = "IPv4 address.";
      };

      ipv6.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable IPv6 networking.";
      };

      ipv6.address = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "IPv6 address.";
      };

      nameserver = lib.mkOption {
        type = lib.listOf lib.types.str;
        default = ["8.8.8.8" "8.8.4.4"];
        description = "DNS nameserver.";
      };
    };
  };

  config = lib.mkMerge [ipv4 ipv6 cfg];
}
