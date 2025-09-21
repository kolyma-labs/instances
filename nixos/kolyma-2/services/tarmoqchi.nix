{
  config,
  inputs,
  ...
}: let
  cfg = config.services.tarmoqchi;

  management = {
    owner = config.services.tarmoqchi.user;
  };
in {
  imports = [inputs.tarmoqchi.nixosModules.tarmoqchi];

  sops.secrets = {
    "tarmoqchi/database" = management;
    "tarmoqchi/github/id" = management;
    "tarmoqchi/github/secret" = management;
  };

  environment.etc = {
    "acme/rfc2136.env".text = ''
      RFC2136_TSIG_KEY=acme-key
      RFC2136_TSIG_SECRET=Q06/9d+NXw6eE5Z0S4Envkh4RKZZb96aM7V8M0SEqppguaeVNmO85qcCG80MGGWiqGO+qsy2bL9LkMNUpKGVgw==
      RFC2136_TSIG_ALGO=hmac-sha512.
      RFC2136_NAMESERVER=ns1.kolyma.uz
    '';
  };

  # Enable tarmoqchi server
  services.tarmoqchi = {
    enable = true;
    port = 9876;
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
      environmentFile = "/etc/acme/rfc2136.env";
      extraDomainNames = ["*.tarmoqchi.uz"];
    };
  };

  services.www.hosts = {
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
}
