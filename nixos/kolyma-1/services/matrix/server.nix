{
  lib,
  config,
  domains,
  keys,
}: let
  sopsFile = ../../../../secrets/efael.yaml;
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
        app_name: "Efael's Network"
        enable_notifs: true
        notif_for_new_users: true
        client_base_url: "https://${domains.server}"
        validation_token_lifetime: "15m"
        invite_client_location: "https://${domains.client}"
        notif_from: "Efael's Support from <noreply@${domains.main}>"
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

      turn_allow_guests = true;
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
              names = [
                "client"
                "federation"
                "keys"
                "media"
                "openid"
                "replication"
                "static"
              ];
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

      rc_message = {
        # This needs to match at least e2ee key sharing frequency plus a bit of headroom
        # Note key sharing events are bursty
        per_second = 0.5;
        burst_count = 30;
      };
      rc_delayed_event_mgmt = {
        # This needs to match at least the heart-beat frequency plus a bit of headroom
        # Currently the heart-beat is every 5 seconds which translates into a rate of 0.2s
        per_second = 1;
        burst_count = 20;
      };

      withJemalloc = true;
    };
  };
}
