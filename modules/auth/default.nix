{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.auth;

  # Shortcut domains
  base = "floss.uz";
  domain = "auth.${base}";
in {
  options = {
    kolyma.auth = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Setup Keycloak IDM service.";
      };

      realm = lib.mkOption {
        description = "Name of the realm";
        type = lib.types.str;
        default = base;
      };

      password = lib.mkOption {
        description = "Database password file path";
        type = lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;

      extraConfig = ''
        access_log /var/log/nginx/${domain}-access.log;
        error_log /var/log/nginx/${domain}-error.log;
      '';

      locations = {
        "= /" = {
          extraConfig = ''
            return 302 /realms/${cfg.realm}/account;
          '';
        };

        "/" = {
          extraConfig = ''
            proxy_pass http://${
              config.services.keycloak.settings.http-host
            }:${
              toString config.services.keycloak.settings.http-port
            };
            proxy_buffer_size 8k;
          '';
        };
      };
    };

    services.keycloak = {
      inherit (cfg) enable;
      database = {
        type = "postgresql";
        passwordFile = cfg.password;
      };
      settings = {
        hostname = domain;
        http-host = "127.0.0.1";
        http-port = 8080;
        proxy-headers = "xforwarded";
        http-enabled = true;
      };
    };
  };
}
