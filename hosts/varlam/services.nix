{
  inputs,
  outputs,
  config,
  ...
}:
{
  imports = [
    # Top level abstractions
    outputs.nixosModules.auth
    outputs.nixosModules.bind
    outputs.nixosModules.mail
    outputs.nixosModules.matrix
    outputs.nixosModules.web

    # Per app preconfigured abstractions
    outputs.nixosModules.apps.floss-website
  ];

  sops.secrets = {
    "auth/database" = {
      sopsFile = ../../secrets/floss.yaml;
    };

    # Matrix oriented secrets
    "matrix/server" = {
      format = "binary";
      owner = "matrix-synapse";
      sopsFile = ../../secrets/matrix/server.hell;
    };
    "matrix/authentication" = {
      format = "binary";
      owner = "matrix-authentication-service";
      sopsFile = ../../secrets/matrix/authentication.hell;
    };
  };

  # Kolyma services
  kolyma = {
    # https://ns1.kolyma.uz
    www = {
      enable = true;
      instance = 1;
      alias = [ "kolyma.uz" ];
    };

    # bind://ns1.kolyma.uz
    nameserver = {
      enable = true;
      type = "master";
    };

    # https://auth.floss.uz
    auth = {
      enable = true;
      password = config.sops.secrets."auth/database".path;
    };

    # (smtp|imap)://mail.kolyma.uz
    mail = {
      enable = true;
      domain = "kolyma.uz";
      alias = [
        "floss.uz"
        "oss.uzinfocom.uz"
      ];
    };

    # https://(chat|matrix).floss.uz
    matrix = {
      enable = true;
      domain = "floss.uz";

      synapse.extra-config-files = [
        config.sops.secrets."matrix/server".path
      ];

      matrix-authentication-service.extra-config-files = [
        config.sops.secrets."matrix/authentication".path
      ];
    };

    # *://*
    apps = {
      # https://floss.uz
      floss.website.enable = true;
    };
  };
}
