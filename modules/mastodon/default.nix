{
  lib,
  config,
  flake,
  ...
}: let
  cfg = config.kolyma.mastodon;
in {
  imports = [
    # Proxy configurations
    ./proxy.nix

    # Unstable module
    "${flake.self.inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/mastodon.nix"
  ];

  disabledModules = [
    "services/web-apps/mastodon.nix"
  ];

  options = {
    kolyma.mastodon = {
      enable = {
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

      record = {
        deterministic-key = lib.mkOption {};
        derivation-salt = lib.mkOption {};
        primary-key = lib.mkOption {};
      };

      secret-key =
        lib.mkOption {
        };

      vapid = {
        public = lib.mkOption {};
        private = lib.mkOption {};
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Nginx user needs access to mastodon unix sockets
    users.users.nginx.extraGroups = ["mastodon"];

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
      activeRecordEncryptionDeterministicKeyFile = "/run/agenix/mastodon-active-record-encryption-deterministic-key";
      activeRecordEncryptionKeyDerivationSaltFile = "/run/agenix/mastodon-active-record-encryption-key-derivation-salt";
      activeRecordEncryptionPrimaryKeyFile = "/run/agenix/mastodon-active-record-encryption-primary-key";
      secretKeyBaseFile = "/run/agenix/mastodon-secret-key-base";
      vapidPrivateKeyFile = "/run/agenix/mastodon-vapid-private-key";
      vapidPublicKeyFile = "/run/agenix/mastodon-vapid-public-key";
      smtp = {
        createLocally = false;
        host = "mail.${cfg.domain}";
        port = 587;
        authenticate = true;
        user = "support@${cfg.domain}";
        passwordFile = "/run/agenix/mastodon-smtp-password";
        fromAddress = "support@${cfg.domain}";
      };
      # Defined in ./opensearch.nix
      elasticsearch.host = "127.0.0.1";
      mediaAutoRemove = {
        olderThanDays = 7;
      };
      extraEnvFiles = ["/run/agenix/mastodon-extra-env-secrets"];
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
        OIDC_REDIRECT_URI = "https://mastodon.${config.pub-solar-os.networking.domain}/auth/auth/openid_connect/callback";
        OIDC_SECURITY_ASSUME_EMAIL_IS_VERIFIED = "true";
        # only use OIDC for login / registration
        OMNIAUTH_ONLY = "true";
      };
    };
  };
}
