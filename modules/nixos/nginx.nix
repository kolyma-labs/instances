{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.www;

  fallbacks = cfg:
    [
      "www.${cfg.domain}"
    ]
    ++ cfg.alias;

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
      virtualHosts = {
        ${cfg.domain} = {
          forceSSL = true;
          enableACME = true;
          serverAliases = fallbacks cfg;
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

  merge = lib.mkMerge [
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

      domain = lib.mkOption {
        type = lib.types.str;
        default = "kolyma.uz";
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
        description = "List of hosted container instances.";
      };
    };
  };

  config = lib.mkIf config.services.www.enable merge;
}
