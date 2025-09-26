{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.www;

  default = {
    # Configure Nginx
    services.nginx = {
      # Enable the Nginx web server
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      # Default virtual host
      virtualHosts =
        if (cfg.domain == "")
        then {
          "default_server" = {
            default = true;
            root = "${pkgs.personal.gate}/www";
          };
        }
        else {
          ${cfg.domain} = {
            default = true;
            forceSSL = true;
            enableACME = true;
            serverAliases = cfg.alias;
            root = "${pkgs.personal.gate}/www";
          };
        };
    };

    # Accepting ACME Terms
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "admin@kolyma.uz";
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
      virtualHosts = cfg.hosts;
    };
  };

  asserts = {
    assertions = [
      {
        assertion = !((builtins.length cfg.alias) != 0 && cfg.domain == "");
        message = "don't set aliases if there's no primary domain yet";
      }
    ];
  };

  merge = lib.mkMerge [
    extra
    asserts
    default
  ];
in {
  options = {
    services.www = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the web server/proxy";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The default domain of instance.";
      };

      alias = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of extra aliases to host.";
      };

      hosts = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "List of hosted services instances.";
      };
    };
  };

  config = lib.mkIf config.services.www.enable merge;
}
