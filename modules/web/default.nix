{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.kolyma.www;

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

  anubis = lib.mkIf config.kolyma.www.anubis {
    users.users.nginx.extraGroups = [config.users.groups.anubis.name];
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
    anubis
    asserts
    default
  ];
in {
  options = {
    kolyma.www = {
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

      anubis = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Add nginx user to anubis group for unix socket access";
      };

      hosts = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "List of hosted services instances.";
      };
    };
  };

  config = lib.mkIf config.kolyma.www.enable merge;

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
