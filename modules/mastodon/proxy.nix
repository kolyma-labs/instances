{
  config,
  lib,
  ...
}: let
  cfg = config.kolyma.mastodon;
  mstdn = config.services.mastodon;

  nginxCommonHeaders = ''
    add_header Cache-Control 'public, max-age=2419200, must-revalidate';
    add_header Strict-Transport-Security 'max-age=63072000';
  '';

  vHostDomain = "social.${cfg.domain}";
in {
  config = lib.mkIf (cfg.enable && config.services.nginx.enable) {
    services.nginx = {
      proxyCachePath = {
        "mastodon" = {
          enable = true;
          keysZoneName = "mastodon";
          inactive = "7d";
        };
      };
      virtualHosts = {
        ${vHostDomain} = {
          root = "${mstdn.package}/public";
          # mastodon only supports https, but you can override this if you offload tls elsewhere.
          forceSSL = lib.mkDefault true;
          enableACME = lib.mkDefault true;

          extraConfig = ''
            client_max_body_size 99m;
            error_page 404 500 501 502 503 504 /500.html;

            access_log /var/log/nginx/${vHostDomain}-access.log;
            error_log /var/log/nginx/${vHostDomain}-error.log;
          '';

          locations = {
            "/auth/sign_up" = {
              priority = 900;
              extraConfig = ''
                return 302 /auth/sign_in;
              '';
            };

            "/auth/confirmation/new" = {
              priority = 910;
              extraConfig = ''
                return 302 https://auth.${cfg.domain}/realms/${cfg.domain}/login-actions/reset-credentials?client_id=mastodon;
              '';
            };

            "/auth/password/new" = {
              priority = 920;
              extraConfig = ''
                return 302 https://auth.${cfg.domain}/realms/${cfg.domain}/login-actions/reset-credentials?client_id=mastodon;
              '';
            };

            "/" = {
              priority = 1100;
              tryFiles = "$uri @mastodon";
            };

            "/system/" = {
              extraConfig = ''
                add_header Cache-Control 'public, max-age=2419200, immutable';
                add_header Strict-Transport-Security 'max-age=63072000';
                add_header X-Content-Type-Options 'nosniff';
                add_header Content-Security-Policy "default-src 'none'; form-action 'none'";
              '';
              alias = "/var/lib/mastodon/public-system/";
            };

            "^~ /api/v1/streaming" = {
              priority = 3190;
              proxyPass = "http://mastodon-streaming";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_set_header Proxy "";

                proxy_buffering off;
                proxy_redirect off;

                add_header Strict-Transport-Security 'max-age=63072000';

                tcp_nodelay on;
              '';
            };

            "@mastodon" = {
              priority = 4100;
              proxyPass = "http://mastodon-web";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_set_header Proxy "";
                proxy_pass_header Server;

                proxy_buffering on;
                proxy_redirect off;

                proxy_cache ${config.services.nginx.proxyCachePath.mastodon.keysZoneName};
                proxy_cache_valid 200 7d;
                proxy_cache_valid 410 24h;
                proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
                add_header X-Cached $upstream_cache_status;

                tcp_nodelay on;
              '';
            };
          };
        };
      };

      upstreams.mastodon-streaming = {
        extraConfig = ''
          least_conn;
        '';
        servers = builtins.listToAttrs (
          map (i: {
            name = "unix:/run/mastodon-streaming/streaming-${toString i}.socket";
            value.fail_timeout = "0";
          }) (lib.range 1 mstdn.streamingProcesses)
        );
      };
      upstreams.mastodon-web = {
        servers."${
          if mstdn.enableUnixSocket
          then "unix:/run/mastodon-web/web.socket"
          else "127.0.0.1:${toString mstdn.webPort}"
        }".fail_timeout = "0";
      };
    };
  };
}
