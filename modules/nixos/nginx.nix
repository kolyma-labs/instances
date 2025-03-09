{
  config,
  lib,
  pkgs,
  ...
}: let
  fallbacks = config:
    [
      "kolyma.uz"
      "www.kolyma.uz"
    ]
    ++ config.services.www.alias;

  default = {
    # Configure Nginx
    services.nginx = {
      # Enable the Nginx web server
      enable = true;

      # Default virtual host
      virtualHosts = {
        "kolyma.uz" = {
          forceSSL = true;
          enableACME = true;
          serverAliases = fallbacks config;
          root = "${pkgs.personal.gate}/www";
        };
      };
    };

    # Accepting ACME Terms
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "admin@kolyma.uz";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
      };
    };

    # Ensure the firewall allows HTTP and HTTPS traffic
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [
      80
      443
    ];
  };

  extra = {
    # Extra configurations for Nginx
    services.nginx = {
      # User provided hosts
      virtualHosts = config.services.www.hosts;
    };
  };

  cfg = lib.mkMerge [
    default
    extra
  ];
in {
  options = {
    services.www = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the web server/proxy";
      };

      alias = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of extra aliases to host.";
      };

      hosts = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "List of hosted container instances.";
      };
    };
  };

  config = lib.mkIf config.services.www.enable cfg;
}
