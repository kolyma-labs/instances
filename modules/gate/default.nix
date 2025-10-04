{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.services.tarmoqchi;

  management = {
    sopsFile = ../../secrets/gateway.yaml;
    owner = config.services.tarmoqchi.user;
  };
in {
  imports = [
    inputs.tarmoqchi.nixosModules.tarmoqchi
  ];

  options = {
    kolyma.gate = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to deploy tarmoqchi service.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 9876;
        description = "Port to assign gateway to.";
      };
    };
  };

  config = {
    sops.secrets = {
      "tarmoqchi/database" =
        {key = "database";} // management;
      "tarmoqchi/github/id" =
        {key = "github/id";} // management;
      "tarmoqchi/github/secret" =
        {key = "github/secret";} // management;
    };

    services.tarmoqchi = {
      enable = true;
      port = config.kolyma.gate.port;
      proxy-reverse.domain = "tarmoqchi.uz";

      github = {
        id = config.sops.secrets."tarmoqchi/github/id".path;
        secret = config.sops.secrets."tarmoqchi/github/secret".path;
      };

      database = {
        passwordFile = config.sops.secrets."tarmoqchi/database".path;
      };
    };

    security.acme = {
      certs."tarmoqchi.uz" = {
        dnsProvider = "rfc2136";
        dnsPropagationCheck = false;
        extraDomainNames = ["*.tarmoqchi.uz"];

        environmentFile = pkgs.writeTextFile {
          name = "rfc2136.env";
          text = ''
            RFC2136_TSIG_KEY=
            RFC2136_TSIG_SECRET=
            RFC2136_TSIG_ALGO=hmac-sha512.
            RFC2136_NAMESERVER=ns1.kolyma.uz
          '';
        };
      };
    };

    services.nginx.virtualHosts = {
      "${cfg.proxy-reverse.domain}" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };

      "*.${cfg.proxy-reverse.domain}" = {
        forceSSL = true;
        useACMEHost = "tarmoqchi.uz";
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
