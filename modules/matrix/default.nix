{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.matrix;

  publicDomain = "matrix.${cfg.domain}";
  serverDomain = "${cfg.domain}";

  listenerWithMetrics =
    lib.findFirst (listener: listener.type == "metrics")
    (throw "Found no matrix-synapse.settings.listeners.*.type containing string metrics")
    config.services.matrix-synapse.settings.listeners;
  synapseMetricsPort = listenerWithMetrics.port;

  workerDefs = [
    {
      name = "client-1";
      resources = ["client"];
    }
    {
      name = "federation-sender-1";
      resources = [];
    }
    {
      name = "federation-receiver-1";
      resources = ["federation"];
    }
    {
      name = "federation-receiver-2";
      resources = ["federation"];
    }
    {
      name = "federation-receiver-3";
      resources = ["federation"];
    }
    {
      name = "federation-receiver-4";
      resources = ["federation"];
    }
  ];

  subnet = "127.0.200";
  synapse_ip = "${subnet}.10";
  worker_ip_start = 11;
  metrics_port_start = 9101;

  workers =
    lib.imap0 (
      i: def: let
        ip = "${subnet}.${toString (worker_ip_start + i)}";
        metrics_port = metrics_port_start + i;
      in {
        inherit (def) name;
        value = {
          worker_app = "synapse.app.generic_worker";
          worker_listeners = [
            {
              type = "http";
              port = 8008;
              bind_addresses = [ip];
              tls = false;
              x_forwarded = true;
              resources = [{names = def.resources ++ ["health"];}];
            }
            # add a metrics listener to all workers
            # ports will be exposed only with wireguard via firewall rule
            {
              type = "metrics";
              port = metrics_port;
              bind_addresses = ["0.0.0.0"];
              tls = false;
              resources = [{names = ["metrics"];}];
            }
          ];
        };
      }
    )
    workerDefs;

  getWorkerHostsForResource = resource:
    lib.flatten (
      builtins.map (
        worker: let
          listener =
            lib.findFirst (
              listener: lib.any (res: lib.any (name: name == resource) res.names) (listener.resources or [])
            )
            null
            worker.value.worker_listeners;
        in
          if listener != null
          then ["${builtins.head listener.bind_addresses}:${toString listener.port}"]
          else []
      )
      workers
    );

  getWorkerPortForResource = resource:
    lib.flatten (
      builtins.map (
        worker: let
          listener =
            lib.findFirst (
              listener: lib.any (res: lib.any (name: name == resource) res.names) (listener.resources or [])
            )
            null
            worker.value.worker_listeners;
        in
          if listener != null
          then [listener.port]
          else []
      )
      workers
    );

  federationReceivers = getWorkerHostsForResource "federation";
  clientReceivers = getWorkerHostsForResource "client";
  metricsPorts = getWorkerPortForResource "metrics";
in {
  imports = [
    # Matrix Authentication Service
    ./authentication.nix

    # Proxy reversing
    ./proxy
  ];

  options = {
    kolyma.matrix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Matrix deployment module.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        example = "kolyma.uz";
        description = "Domain to associate matrix network with.";
      };

      synapse = {
        app-service-config-files = lib.mkOption {
          description = "List of app service config files";
          type = lib.types.listOf lib.types.str;
          default = [];
        };

        extra-config-files = lib.mkOption {
          description = "List of extra synapse config files";
          type = lib.types.listOf lib.types.str;
          default = [];
        };

        signing_key_path = lib.mkOption {
          description = "Path to file containing the signing key";
          type = lib.types.str;
          default = "${config.services.matrix-synapse.dataDir}/homeserver.signing.key";
        };
      };

      matrix-authentication-service = {
        extra-config-files = lib.mkOption {
          description = "List of extra mas config files";
          type = lib.types.listOf lib.types.str;
          default = [];
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Only expose matrix-synapse metrics ports via wireguard interface
    networking.firewall.interfaces.wg-ssh.allowedTCPPorts = [synapseMetricsPort] ++ metricsPorts;

    # generate nginx upstreams for configured workers
    services = {
      nginx.upstreams = {
        "matrix-synapse".servers = {
          "${synapse_ip}:8008" = {};
        };
        "matrix-federation-receiver".servers = lib.genAttrs federationReceivers (host: {});
        "matrix-client-receiver".servers = lib.genAttrs clientReceivers (host: {});
      };

      matrix-synapse = {
        enable = true;
        log.root.level = "WARNING";
        configureRedisLocally = true;
        workers = builtins.listToAttrs workers;
        settings = {
          server_name = serverDomain;
          public_baseurl = "https://${publicDomain}/";
          database = {
            name = "psycopg2";
            args = {
              host = "/run/postgresql";
              cp_max = 10;
              cp_min = 5;
              database = "matrix";
            };
            allow_unsafe_locale = false;
            txn_limit = 0;
          };

          listeners = [
            {
              bind_addresses = ["${synapse_ip}"];
              port = 8008;
              tls = false;
              type = "http";
              x_forwarded = true;
              resources = [
                {
                  names = [
                    "client"
                    "federation"
                  ];
                }
              ];
            }
            {
              bind_addresses = ["0.0.0.0"];
              port = 9000;
              tls = false;
              type = "metrics";
              resources = [{names = ["metrics"];}];
            }
            {
              path = "/run/matrix-synapse/main_replication.sock";
              mode = "660";
              type = "http";
              resources = [{names = ["replication"];}];
            }
          ];
          federation_sender_instances = ["federation-sender-1"];
          instance_map = {
            main = {
              path = "/run/matrix-synapse/main_replication.sock";
            };
          };

          account_threepid_delegates.msisdn = "";
          alias_creation_rules = [
            {
              action = "allow";
              alias = "*";
              room_id = "*";
              user_id = "*";
            }
          ];
          allow_guest_access = false;
          allow_public_rooms_over_federation = true;
          allow_public_rooms_without_auth = false;
          auto_join_rooms = [
            "#community:${serverDomain}"
            "#general:${serverDomain}"
          ];

          autocreate_auto_join_rooms = true;

          default_room_version = "12";
          disable_msisdn_registration = true;
          enable_media_repo = true;
          media_retention = {
            remote_media_lifetime = "14d";
          };
          enable_metrics = true;
          federation_metrics_domains = [
            "matrix.org"
            "mozilla.org"
            "systemli.org"
            "tchncs.de"
            "ccc.ac"
            "fairydust.space"
          ];
          mau_stats_only = true;
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

          # https://github.com/element-hq/synapse/issues/11203
          # No YAML deep-merge, so this needs to be in secret extraConfigFiles
          # together with msc3861
          #experimental_features = {
          #  # MSC3266: Room summary API. Used for knocking over federation
          #  msc3266_enabled: true
          #  # MSC4222 needed for syncv2 state_after. This allow clients to
          #  # correctly track the state of the room.
          #  msc4222_enabled: true
          #  # Rendezvous server for QR Code generation
          #  msc4108_enabled = true;
          #};

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

          rc_admin_redaction = {
            burst_count = 50;
            per_second = 1;
          };
          rc_federation = {
            concurrent = 3;
            reject_limit = 50;
            sleep_delay = 500;
            sleep_limit = 10;
            window_size = 1000;
          };
          rc_invites = {
            per_issuer = {
              burst_count = 10;
              per_second = 0.3;
            };
            per_room = {
              burst_count = 10;
              per_second = 0.3;
            };
            per_user = {
              burst_count = 5;
              per_second = 3.0e-3;
            };
          };
          rc_joins = {
            local = {
              burst_count = 10;
              per_second = 0.1;
            };
            remote = {
              burst_count = 10;
              per_second = 1.0e-2;
            };
          };
          rc_login = {
            account = {
              burst_count = 3;
              per_second = 0.17;
            };
            address = {
              burst_count = 3;
              per_second = 0.17;
            };
            failed_attempts = {
              burst_count = 3;
              per_second = 0.17;
            };
          };
          rc_message = {
            # This needs to match at least e2ee key sharing frequency plus a bit of headroom
            # Note key sharing events are bursty
            burst_count = 30;
            per_second = 0.5;
          };
          rc_delayed_event_mgmt = {
            # This needs to match at least the heart-beat frequency plus a bit of headroom
            # Currently the heart-beat is every 5 seconds which translates into a rate of 0.2s
            per_second = 1;
            burst_count = 20;
          };
          rc_registration = {
            burst_count = 3;
            per_second = 0.17;
          };
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

          signing_key_path = config.kolyma.matrix.synapse.signing_key_path;

          stream_writers = {};
          trusted_key_servers = [{server_name = "matrix.org";}];
          suppress_key_server_warning = true;

          turn_allow_guests = false;
          turn_uris = [
            "turn:${config.services.coturn.realm}:3478?transport=udp"
            "turn:${config.services.coturn.realm}:3478?transport=tcp"
          ];
          turn_user_lifetime = "1h";

          url_preview_accept_language = [
            "en-US"
            "en"
          ];
          url_preview_enabled = true;
          url_preview_ip_range_blacklist = [
            "127.0.0.0/8"
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "100.64.0.0/10"
            "192.0.0.0/24"
            "169.254.0.0/16"
            "192.88.99.0/24"
            "198.18.0.0/15"
            "192.0.2.0/24"
            "198.51.100.0/24"
            "203.0.113.0/24"
            "224.0.0.0/4"
            "::1/128"
            "fe80::/10"
            "fc00::/7"
            "2001:db8::/32"
            "ff00::/8"
            "fec0::/10"
          ];

          user_directory = {
            prefer_local_users = false;
            search_all_users = false;
          };
          user_ips_max_age = "28d";

          app_service_config_files = config.kolyma.matrix.synapse.app-service-config-files;
        };

        withJemalloc = true;

        extraConfigFiles = config.kolyma.matrix.synapse.extra-config-files;

        extras = [
          "oidc"
        ];

        plugins = with config.services.matrix-synapse.package.plugins; [
          matrix-synapse-shared-secret-auth
          synapse-http-antispam
        ];
      };

      matrix-authentication-service = {
        enable = true;
        createDatabase = true;
        extraConfigFiles = config.kolyma.matrix.matrix-authentication-service.extra-config-files;

        # https://element-hq.github.io/matrix-authentication-service/reference/configuration.html
        settings = {
          account.email_change_allowed = false;
          http = {
            public_base = "https://mas.${cfg.domain}";
            issuer = "https://mas.${cfg.domain}";
            listeners = [
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
          passwords.enabled = false;
        };
      };
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
