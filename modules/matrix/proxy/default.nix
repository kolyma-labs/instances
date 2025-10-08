{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.kolyma.matrix;

  commonHeaders = ''
    add_header Permissions-Policy interest-cohort=() always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
    add_header X-XSS-Protection "1; mode=block";
  '';
  matrixHeaders = ''
    ${commonHeaders}

    # Should match synapse homeserver setting max_upload_size
    client_max_body_size 50M;
    # The maximum body size for client requests to any of the endpoints on the Client-Server API.
    # This needs to be equal or higher than the maximum upload size accepted by Synapse.
    client_body_buffer_size 50M;
    proxy_max_temp_file_size 0;
  '';
  clientConfig = import ./element-client-config.nix {inherit config lib pkgs;};
  wellKnownClient = domain: {
    "m.homeserver".base_url = "https://matrix.${domain}";
    "m.identity_server".base_url = "https://matrix.${domain}";
    "org.matrix.msc2965.authentication" = {
      issuer = "https://mas.${domain}/";
      account = "https://mas.${domain}/account";
    };
    "im.vector.riot.e2ee".default = true;
    "io.element.e2ee" = {
      default = true;
      secure_backup_required = false;
      secure_backup_setup_methods = [];
    };
    "org.matrix.msc4143.rtc_foci" = [
      {
        "type" = "livekit";
        "livekit_service_url" = "https://livekit-jwt.call.matrix.org";
      }
    ];
  };
  wellKnownServer = domain: {"m.server" = "matrix.${domain}:8448";};
  wellKnownSupport = {
    contacts = [
      {
        email_address = "support@floss.uz";
        matrix_id = "@orzklv:floss.uz";
        role = "m.role.admin";
      }
    ];
    support_page = "https://${cfg.domain}/about";
  };
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
  wellKnownLocations = domain: {
    "= /.well-known/matrix/server".extraConfig = mkWellKnown (wellKnownServer domain);
    "= /.well-known/matrix/client".extraConfig = mkWellKnown (wellKnownClient domain);
    "= /.well-known/matrix/support".extraConfig = mkWellKnown wellKnownSupport;
  };
  mkLocation = type: endpoint: {
    "~* ${endpoint}" = {
      extraConfig = ''
        ${commonHeaders}
        add_header x-backend "worker-${type}" always;
      '';
      proxyPass = "http://matrix-${type}-receiver";
      priority = 175;
    };
  };

  mkEndpoints = type: file: let
    rawEndpoints = lib.splitString "\n" (builtins.readFile file);
    filteredEndpoints = builtins.filter (e: e != "" && (!lib.hasPrefix "#" e)) rawEndpoints;
    mkLocation' = mkLocation type;
  in
    builtins.map mkLocation' filteredEndpoints;
  endpoints =
    (mkEndpoints "client" ./endpoints/client.txt)
    ++ (mkEndpoints "federation" ./endpoints/federation.txt);
in {
  services.nginx.upstreams = {
    "matrix-federation-receiver-hash" = {
      servers = config.services.nginx.upstreams."matrix-federation-receiver".servers;
      extraConfig = ''
        hash $remote_addr;
      '';
    };
  };

  services.nginx.virtualHosts =
    lib.mkIf
    (config.kolyma.matrix.enable && config.services.nginx.enable)
    {
      "${cfg.domain}" = {
        locations = wellKnownLocations "${cfg.domain}";
      };

      "chat.${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        root = pkgs.element-web.override {conf = clientConfig;};
        extraConfig = ''
          ${commonHeaders}

          access_log /var/log/nginx/chat.${cfg.domain}-access.log combined_host;
          error_log /var/log/nginx/chat.${cfg.domain}-error.log;
        '';
      };

      "stickers.chat.${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        root = pkgs.element-stickerpicker;
        extraConfig = ''
          ${commonHeaders}

          access_log /var/log/nginx/stickers.chat.${cfg.domain}-access.log combined_host;
          error_log /var/log/nginx/stickers.chat.${cfg.domain}-error.log;
        '';
      };

      "mas.${cfg.domain}" = {
        root = "/dev/null";

        forceSSL = lib.mkDefault true;
        enableACME = lib.mkDefault true;

        extraConfig = ''
          ${commonHeaders}

          access_log /var/log/nginx/mas.${cfg.domain}-access.log combined_host;
          error_log /var/log/nginx/mas.${cfg.domain}-error.log;
        '';

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8090";
          };
        };
      };

      "matrix.${cfg.domain}" = {
        listen = [
          {
            port = 80;
            addr = "0.0.0.0";
            ssl = false;
          }
          {
            port = 80;
            addr = "[::]";
            ssl = false;
          }
          {
            port = 443;
            addr = "0.0.0.0";
            ssl = true;
          }
          {
            port = 443;
            addr = "[::]";
            ssl = true;
          }
          # For the federation port
          {
            port = 8448;
            addr = "0.0.0.0";
            ssl = true;
          }
          {
            port = 8448;
            addr = "[::]";
            ssl = true;
          }
        ];

        root = "/dev/null";

        forceSSL = lib.mkDefault true;
        enableACME = lib.mkDefault true;

        extraConfig = ''
          access_log /var/log/nginx/matrix.${cfg.domain}-access.log combined_host;
          error_log /var/log/nginx/matrix.${cfg.domain}-error.log;
        '';

        locations = lib.foldl' lib.recursiveUpdate {} (
          [
            {
              # For telegram
              "/c3c3f34b-29fb-5feb-86e5-98c75ec8214b" = {
                priority = 100;
                proxyPass = "http://127.0.0.1:8009";
                extraConfig = commonHeaders;
              };

              # For IRC appservice media proxy
              "/media" = {
                priority = 100;
                proxyPass = "http://127.0.0.1:${toString (config.services.matrix-appservice-irc.settings.ircService.mediaProxy.bindPort)}";
                extraConfig = commonHeaders;
              };

              # Forward to the auth service
              "~ ^/_matrix/client/(.*)/(login|logout|refresh)" = {
                priority = 100;
                proxyPass = "http://127.0.0.1:8090";
                extraConfig = commonHeaders;
              };

              # draupnir reports
              "~* ^/_matrix/client/(r0|v3)/rooms/([^/]*)/report/(.*)$" = {
                extraConfig = ''
                  set $room_id $2;
                  set $event_id $3;
                  add_header x-backend "draupnir" always;
                  ${matrixHeaders}
                '';
                proxyPass = "http://127.0.200.101:8080/api/1/report/$room_id/$event_id";
                priority = 150;
              };

              # load-balancing for inbound federation transaction requests
              "~* ^/_matrix/federation/v1/send/" = {
                extraConfig = ''
                  ${matrixHeaders}
                  add_header x-backend "worker-federation" always;
                '';
                proxyPass = "http://matrix-federation-receiver-hash";
                priority = 150;
              };

              # Disable compression for QR code to work
              # https://github.com/element-hq/synapse/issues/18155#issuecomment-2671793213
              "~ ^/_synapse/client/rendezvous/" = {
                priority = 175;
                proxyPass = "http://matrix-synapse";

                extraConfig = ''
                  ${matrixHeaders}
                  add_header x-backend "synapse" always;
                  gzip off;
                '';
              };

              # Forward to Synapse
              # as per https://element-hq.github.io/synapse/latest/reverse_proxy.html#nginx
              "~ ^(/_matrix|/_synapse)" = {
                priority = 200;
                proxyPass = "http://matrix-synapse";

                extraConfig = ''
                  ${matrixHeaders}
                  add_header x-backend "synapse" always;
                '';
              };
            }
          ]
          ++ endpoints
        );
      };
    };
  networking.firewall.allowedTCPPorts = [8448];
}
