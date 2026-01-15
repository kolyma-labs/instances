{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.kolyma.mastodon;
in
{
  imports = [
    # Proxy configurations
    ./proxy.nix

    # Unstable module
    "${inputs.mastodon-backport}/nixos/modules/services/web-apps/mastodon.nix"
  ];

  disabledModules = [
    "services/web-apps/mastodon.nix"
  ];

  options = {
    kolyma.mastodon = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether to deploy mastodon instance in this server.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        example = "example.com";
        description = "The domain to which mastodon is going to be associated with.";
      };

      mail = lib.mkOption {
        type = lib.types.path;
        default = config.sops.secrets."mastodon/mail".path;
        description = "Path to file containing password of mail server.";
      };

      record = {
        deterministic-key = lib.mkOption {
          type = lib.types.path;
          default = config.sops.secrets."mastodon/record-deterministic-key".path;
          description = "This key must be set to enable the Active Record Encryption feature.";
        };
        derivation-salt = lib.mkOption {
          type = lib.types.path;
          default = config.sops.secrets."mastodon/record-derivation-salt".path;
          description = "This key must be set to enable the Active Record Encryption feature.";
        };
        primary-key = lib.mkOption {
          type = lib.types.path;
          default = config.sops.secrets."mastodon/record-primary-key".path;
          description = "This key must be set to enable the Active Record Encryption feature.";
        };
      };

      secret-key = lib.mkOption {
        type = lib.types.path;
        default = config.sops.secrets."mastodon/secret-key".path;
        description = "Path to file containing the secret key base.";
      };

      vapid = {
        public = lib.mkOption {
          type = lib.types.path;
          default = config.sops.secrets."mastodon/vapid-public".path;
          description = "Path to file containing the public key used for Web Push Voluntary Application Server Identification.";
        };
        private = lib.mkOption {
          type = lib.types.path;
          default = config.sops.secrets."mastodon/vapid-private".path;
          description = "Path to file containing the public key used for Web Push Voluntary Application Server Identification.";
        };
      };

      env = lib.mkOption {
        type = lib.types.path;
        default = config.sops.secrets."mastodon/extra".path;
        description = "Some extra environmental variables to append to service.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "mastodon/mail" = {
        key = "mail/raw";
        owner = config.services.mastodon.user;
        sopsFile = ../../secrets/mail.yaml;
      };
      "mastodon/record-deterministic-key" = {
        key = "record/deterministic-key";
        owner = config.services.mastodon.user;
        sopsFile = ../../secrets/mastodon/secrets.yaml;
      };
      "mastodon/record-derivation-salt" = {
        key = "record/derivation-salt";
        owner = config.services.mastodon.user;
        sopsFile = ../../secrets/mastodon/secrets.yaml;
      };
      "mastodon/record-primary-key" = {
        key = "record/primary-key";
        owner = config.services.mastodon.user;
        sopsFile = ../../secrets/mastodon/secrets.yaml;
      };
      "mastodon/secret-key" = {
        format = "binary";
        owner = config.services.mastodon.user;
        sopsFile = ../../secrets/mastodon/secret-key.hell;
      };
      "mastodon/vapid-public" = {
        key = "public";
        owner = config.services.mastodon.user;
        sopsFile = ../../secrets/mastodon/vapid.yaml;
      };
      "mastodon/vapid-private" = {
        key = "private";
        owner = config.services.mastodon.user;
        sopsFile = ../../secrets/mastodon/vapid.yaml;
      };
      "mastodon/extra" = {
        format = "binary";
        owner = config.services.mastodon.user;
        sopsFile = ../../secrets/mastodon/env.hell;
      };
    };

    # Nginx user needs access to mastodon unix sockets
    users.users.nginx.extraGroups = [ "mastodon" ];

    services.opensearch.enable = true;

    services.mastodon = {
      enable = true;
      # Different from WEB_DOMAIN in our case
      localDomain = "${cfg.domain}";
      enableUnixSocket = true;
      # Number of processes used by the mastodon-streaming service
      # Recommended is the amount of your CPU cores minus one
      # On our current 8-Core system, let's start with 5 for now
      streamingProcesses = 5;
      # Processes used by the mastodon-web service
      webProcesses = 2;
      # Threads per process used by the mastodon-web service
      webThreads = 5;
      activeRecordEncryptionDeterministicKeyFile = cfg.record.deterministic-key;
      activeRecordEncryptionKeyDerivationSaltFile = cfg.record.derivation-salt;
      activeRecordEncryptionPrimaryKeyFile = cfg.record.primary-key;
      secretKeyBaseFile = cfg.secret-key;
      vapidPrivateKeyFile = cfg.vapid.private;
      vapidPublicKeyFile = cfg.vapid.public;
      smtp = {
        createLocally = false;
        host = "mail.kolyma.uz";
        port = 587;
        authenticate = true;
        user = "support@${cfg.domain}";
        passwordFile = cfg.mail;
        fromAddress = "support@${cfg.domain}";
      };

      elasticsearch.host = "127.0.0.1";

      mediaAutoRemove = {
        olderThanDays = 7;
      };

      extraEnvFiles = [ cfg.env ];
      extraConfig = {
        WEB_DOMAIN = "social.${cfg.domain}";

        # -----------------------
        # S3 File storage (maybe in the future?)
        # -----------------------
        # S3_ENABLED = "true";
        # S3_BUCKET = "mastodon";
        # S3_REGION = "eu-central";
        # S3_ENDPOINT = "https://buckets.floss.uz";
        # S3_ALIAS_HOST = "files.${cfg.domain}";
        # S3_OPEN_TIMEOUT = "10";
        # S3_READ_TIMEOUT = "10";

        # -----------------------
        # Translation (optional)
        # -----------------------
        DEEPL_PLAN = "free";

        # -----------------------
        # OpenID Connect
        # -----------------------
        OIDC_ENABLED = "true";
        OIDC_DISPLAY_NAME = "${cfg.domain} member";
        OIDC_ISSUER = "https://auth.${cfg.domain}/realms/${cfg.domain}";
        OIDC_DISCOVERY = "true";
        OIDC_SCOPE = "openid,profile,email";
        OIDC_UID_FIELD = "preferred_username";
        OIDC_REDIRECT_URI = "https://social.${cfg.domain}/auth/auth/openid_connect/callback";
        OIDC_SECURITY_ASSUME_EMAIL_IS_VERIFIED = "true";
        # only use OIDC for login / registration
        OMNIAUTH_ONLY = "true";
      };
    };
  };
}
