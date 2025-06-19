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
      RFC2136_TSIG_KEY=
      RFC2136_TSIG_SECRET=
      RFC2136_TSIG_ALGO=hmac-sha512.
      RFC2136_NAMESERVER=ns2.kolyma.uz
    '';
  };

  # Enable tarmoqchi server
  services.tarmoqchi = {
    enable = true;
    port = 9876;

    proxy-reverse = {
      enable = false;
      domain = "tarmoqchi.uz";
      proxy = "nginx";
    };

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
      addSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
    "*.${cfg.proxy-reverse.domain}" = {
      addSSL = true;
      useACMEHost = "tarmoqchi.uz";
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
  };
}
