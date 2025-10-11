{
  inputs,
  outputs,
  config,
  ...
}: {
  imports = [
    outputs.nixosModules.auth
    outputs.nixosModules.bind
    outputs.nixosModules.mail
    outputs.nixosModules.matrix
    outputs.nixosModules.web

    inputs.floss-website.nixosModules.kolyma
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
    # Web Server & Proxy
    www = {
      enable = true;
      instance = 1;
      alias = ["kolyma.uz"];
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "master";
    };

    # Keycloak Management
    auth = {
      enable = true;
      password = config.sops.secrets."auth/database".path;
    };

    mail = {
      enable = true;
      domain = "floss.uz";
    };

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
  };

  floss = {
    website.enable = true;
  };
}
