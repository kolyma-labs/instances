{
  config,
  domains,
}: let
  sopsFile = ../../../../secrets/matrix.yaml;
  owner = config.systemd.services.matrix-authentication-service.serviceConfig.User;
in {
  sops.secrets = {
    # Mail
    "matrix/mas/mail" = {
      inherit owner sopsFile;
      key = "mail/support/raw";
    };

    # Client
    "matrix/mas/client/id" = {
      inherit owner sopsFile;
      key = "client/id";
    };
    "matrix/mas/client/secret" = {
      inherit owner sopsFile;
      key = "client/secret";
    };

    # Keys
    "matrix/mas/keys/encryption" = {
      inherit owner sopsFile;
      key = "client/secret";
    };
    "matrix/mas/keys/DQhwdhHMxc" = {
      inherit owner sopsFile;
      key = "keys/keys/DQhwdhHMxc";
    };
    "matrix/mas/keys/fK7g4m3Ozg" = {
      inherit owner sopsFile;
      key = "keys/keys/fK7g4m3Ozg";
    };
    "matrix/mas/keys/cePSmzchGk" = {
      inherit owner sopsFile;
      key = "keys/keys/cePSmzchGk";
    };
    "matrix/mas/keys/SxnO3hEMCg" = {
      inherit owner sopsFile;
      key = "keys/keys/SxnO3hEMCg";
    };
  };

  sops.templates."extra-mas-conf.yaml" = {
    inherit owner;
    content = ''
      email:
        from: '"Efael" <noreply@${domains.main}>'
        reply_to: '"No reply" <noreply@${domains.main}>'
        transport: smtp
        mode: tls  # plain | tls | starttls
        hostname: ${domains.mail}
        port: 587
        username: noreply@${domains.main}
        password: "${config.sops.placeholder."matrix/mas/mail"}"
      clients:
        - client_id: ${config.sops.placeholder."matrix/mas/client/id"}
          client_auth_method: client_secret_basic
          client_secret: "${config.sops.placeholder."matrix/mas/client/secret"}"
      matrix:
        kind: synapse
        homeserver: ${domains.main}
        secret: "${config.sops.placeholder."matrix/mas/client/secret"}"
        endpoint: "https://${domains.server}"
      secrets:
        encryption: ${config.sops.placeholder."matrix/mas/keys/encryption"}
        keys:
          - kid: DQhwdhHMxc
            key: |
              ${config.sops.placeholder."matrix/mas/keys/DQhwdhHMxc"}
          - kid: fK7g4m3Ozg
            key: |
              ${config.sops.placeholder."matrix/mas/keys/fK7g4m3Ozg"}
          - kid: cePSmzchGk
            key: |
              ${config.sops.placeholder."matrix/mas/keys/cePSmzchGk"}
          - kid: SxnO3hEMCg
            key: |
              ${config.sops.placeholder."matrix/mas/keys/SxnO3hEMCg"}
    '';
  };

  services.matrix-authentication-service = {
    enable = true;
    createDatabase = true;
    extraConfigFiles = [
      config.sops.templates."extra-mas-conf.yaml".path
    ];

    settings = {
      http = {
        public_base = "https://${domains.auth}";
        issuer = "https://${domains.auth}";
        listener = [
          {
            name = "web";
            resources = [
              {name = "discovery";}
              {name = "human";}
              {name = "oauth";}
              {name = "compat";}
              {name = "graphql";}
              {
                name = "assets";
                path = "${config.services.matrix-authentication-service.package}/share/matrix-authentication-service/assets";
              }
            ];
            binds = [
              {
                host = "0.0.0.0";
                port = 8090;
              }
            ];
            proxy_protocol = false;
          }
          {
            name = "internal";
            resources = [
              {name = "health";}
            ];
            binds = [
              {
                host = "0.0.0.0";
                port = 8081;
              }
            ];
            proxy_protocol = false;
          }
        ];
      };

      account = {
        email_change_allowed = true;
        displayname_change_allowed = true;
        password_registration_enabled = true;
        password_change_allowed = true;
        password_recovery_enabled = true;
      };

      passwords = {
        enabled = true;
        minimum_complexity = 3;
        schemes = [
          {
            version = 1;
            algorithm = "argon2id";
          }
          {
            version = 2;
            algorithm = "bcrypt";
          }
        ];
      };
    };
  };
}
