{
  lib,
  config,
  domains,
  keys,
}: let
  sopsFile = ../../../../secrets/floss.yaml;
  owner = config.systemd.services.matrix-synapse.serviceConfig.User;
in {
  sops.secrets = {
    "matrix/synapse/mail" = {
      inherit owner sopsFile;
      key = "mail/support/raw";
    };
    "matrix/synapse/client/id" = {
      inherit owner sopsFile;
      key = "matrix/id";
    };
    "matrix/synapse/client/secret" = {
      inherit owner sopsFile;
      key = "matrix/secret";
    };
    "matrix/synapse/github/id" = {
      inherit owner sopsFile;
      key = "matrix/oath/github/id";
    };
    "matrix/synapse/github/secret" = {
      inherit owner sopsFile;
      key = "matrix/oath/github/secret";
    };
    "matrix/synapse/mastodon/id" = {
      inherit owner sopsFile;
      key = "matrix/oath/mastodon/id";
    };
    "matrix/synapse/mastodon/secret" = {
      inherit owner sopsFile;
      key = "matrix/oath/mastodon/secret";
    };
  };

  sops.templates."extra-matrix-conf.yaml" = {
    inherit owner;
    content = ''
      email:
        smtp_host: "${domains.mail}"
        smtp_port: 587
        smtp_user: "support@${domains.main}"
        smtp_pass: "${config.sops.placeholder."matrix/synapse/mail"}"
        enable_tls: true
        force_tls: false
        require_transport_security: true
        app_name: "Floss Network"
        enable_notifs: true
        notif_for_new_users: true
        client_base_url: "https://${domains.server}"
        validation_token_lifetime: "15m"
        invite_client_location: "https://${domains.client}"
        notif_from: "Floss Support from <noreply@${domains.main}>"
      oidc_providers:
        - idp_id: github
          idp_name: Github
          idp_brand: "github"
          discover: false
          issuer: "https://github.com/"
          client_id: "${config.sops.placeholder."matrix/synapse/github/id"}"
          client_secret: "${config.sops.placeholder."matrix/synapse/github/secret"}"
          authorization_endpoint: "https://github.com/login/oauth/authorize"
          token_endpoint: "https://github.com/login/oauth/access_token"
          userinfo_endpoint: "https://api.github.com/user"
          scopes: ["read:user"]
          user_mapping_provider:
            config:
              subject_claim: "id"
              localpart_template: "{{ user.login }}"
              display_name_template: "{{ user.name }}"
        - idp_id: mastodon
          idp_name: Mastodon
          idp_brand: "mastodon"
          discover: false
          issuer: "https://social.floss.uz/@orzklv"
          client_id: "${config.sops.placeholder."matrix/synapse/mastodon/id"}"
          client_secret: "${config.sops.placeholder."matrix/synapse/mastodon/secret"}"
          authorization_endpoint: "https://social.floss.uz/oauth/authorize"
          token_endpoint: "https://social.floss.uz/oauth/token"
          userinfo_endpoint: "https://social.floss.uz/api/v1/accounts/verify_credentials"
          scopes: ["read"]
          user_mapping_provider:
            config:
              subject_template: "{{ user.id }}"
              localpart_template: "{{ user.username }}"
              display_name_template: "{{ user.display_name }}"

      experimental_features:
        msc3861:
          enabled: true
          issuer: https://${domains.auth}/
          client_id: ${config.sops.placeholder."matrix/mas/client/id"}
          client_auth_method: client_secret_basic
          client_secret: "${config.sops.placeholder."matrix/mas/client/secret"}"
          admin_token: "${config.sops.placeholder."matrix/mas/client/secret"}"
          introspection_endpoint: "https://${domains.auth}/oauth2/introspect"
        msc4108_enabled: true
        msc2965_enabled: true
        msc3266_enabled: true
        msc4222_enabled: true
        msc4190_enabled: true
    '';
  };

  services.postgresql = {
    enable = lib.mkDefault true;

    # initialScript = pkgs.writeText "synapse-init.sql" ''
    #   CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD '${temp}';
    #   CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
    #     TEMPLATE template0
    #     LC_COLLATE = "C"
    #     LC_CTYPE = "C";
    # '';
  };

  services.matrix-synapse = {
    enable = true;
    log.root.level = "WARNING";

    configureRedisLocally = true;

    extraConfigFiles = [
      config.sops.templates."extra-matrix-conf.yaml".path
    ];

    extras = lib.mkForce [
      "oidc" # OpenID Connect authentication
      "postgres" # PostgreSQL database backend
      "redis" # Redis support for the replication stream between worker processes
      "systemd" # Provide the JournalHandler used in the default log_config
      "url-preview" # Support for oEmbed URL previews
      "user-search" # Support internationalized domain names in user-search
    ];

    settings = {
      server_name = domains.main;
      public_baseurl = "https://${domains.server}";

      turn_allow_guests = false;
      turn_uris = [
        "turn:${domains.realm}:3478?transport=udp"
        "turn:${domains.realm}:3478?transport=tcp"
      ];
      turn_shared_secret = keys.realmkey;
      turn_user_lifetime = "1h";

      suppress_key_server_warning = true;
      allow_guest_access = true;
      enable_set_displayname = true;
      enable_set_avatar_url = true;

      admin_contact = "mailto:support@${domains.main}";

      listeners = [
        {
          port = 8008;
          bind_addresses = ["127.0.0.1" "::1"];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = ["client" "federation"];
            }
          ];
        }
      ];

      account_threepid_delegates.msisdn = "";
      alias_creation_rules = [
        {
          action = "allow";
          alias = "*";
          room_id = "*";
          user_id = "*";
        }
      ];
      allow_public_rooms_over_federation = true;
      allow_public_rooms_without_auth = false;
      auto_join_rooms = [
        "#community:${domains.main}"
        "#general:${domains.main}"
      ];
      autocreate_auto_join_rooms = true;
      default_room_version = "10";
      disable_msisdn_registration = true;
      enable_media_repo = true;

      enable_registration = false;
      enable_registration_captcha = false;
      enable_registration_without_verification = false;
      enable_room_list_search = true;
      encryption_enabled_by_default_for_room_type = "off";
      event_cache_size = "100K";
      caches.global_factor = 10;

      # Based on https://github.com/spantaleev/matrix-docker-ansible-deploy/blob/37a7af52ab6a803e5fec72d37b0411a6c1a3ddb7/docs/maintenance-synapse.md#tuning-caches-and-cache-autotuning
      # https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html#caches-and-associated-values
      cache_autotuning = {
        max_cache_memory_usage = "4096M";
        target_cache_memory_usage = "2048M";
        min_cache_ttl = "5m";
      };

      # The maximum allowed duration by which sent events can be delayed, as
      # per MSC4140.
      max_event_delay_duration = "24h";

      federation_rr_transactions_per_room_per_second = 50;
      federation_client_minimum_tls_version = "1.2";
      forget_rooms_on_leave = true;
      include_profile_data_on_invite = true;
      limit_profile_requests_to_users_who_share_rooms = false;

      max_spider_size = "10M";
      max_upload_size = "50M";
      media_storage_providers = [];

      password_config = {
        enabled = false;
        localdb_enabled = false;
        pepper = "";
      };

      presence.enabled = true;
      push.include_content = false;

      redaction_retention_period = "7d";
      forgotten_room_retention_period = "7d";
      registration_requires_token = false;
      registrations_require_3pid = ["email"];
      report_stats = false;
      require_auth_for_profile_requests = false;
      room_list_publication_rules = [
        {
          action = "allow";
          alias = "*";
          room_id = "*";
          user_id = "*";
        }
      ];

      user_directory = {
        prefer_local_users = false;
        search_all_users = false;
      };
      user_ips_max_age = "28d";

      withJemalloc = true;

      database.args = {
        database = "matrix-synapse";
        user = "matrix-synapse";
        password = "new_password";
        host = "localhost";
        port = 5432;
      };
    };
  };
}
