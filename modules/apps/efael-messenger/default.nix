{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.kolyma.apps.efael.messenger;

  wellKnownClient = domain: {
    "m.homeserver".base_url = "https://matrix.${domain}";
    "m.identity_server".base_url = "https://matrix.${domain}";
    "org.matrix.msc2965.authentication" = {
      issuer = "https://auth.${domain}/";
      account = "https://auth.${domain}/account";
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
        "livekit_service_url" = "https://livekit-jwt.${cfg.domain}";
      }
    ];
  };

  wellKnownServer = domain: {"m.server" = "matrix.${domain}:443";};

  wellKnownSupport = {
    contacts = [
      {
        email_address = "support@oss.uzinfocom.uz";
        matrix_id = "@orzklv:oss.uzinfocom.uz";
        role = "m.role.admin";
      }
    ];
    support_page = "https://${cfg.domain}";
  };

  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';

  wellKnownAppleLocations = domain: {
    "= /.well-known/apple-app-site-association". extraConfig = let
      data = {
        applinks = {
          apps = [
            "86VMSY4FK5.uz.uzinfocom.efael.app"
            "7J4U792NQT.io.element.elementx"
          ];
          details = [];
        };
        webcredentials = {
          apps = [
            "86VMSY4FK5.uz.uzinfocom.efael.app"
            "7J4U792NQT.io.element.elementx"
          ];
        };
      };
    in ''
      default_type application/json;
      types { application/json apple-app-site-association; }
      return 200 '${builtins.toJSON data}';
    '';
  };

  wellKnownLocations = domain: {
    "= /.well-known/matrix/server".extraConfig = mkWellKnown (wellKnownServer domain);
    "= /.well-known/matrix/client".extraConfig = mkWellKnown (wellKnownClient domain);
    "= /.well-known/matrix/support".extraConfig = mkWellKnown wellKnownSupport;
  };
in {
  imports = [
    inputs.efael-website.nixosModules.server
  ];

  options = {
    kolyma.apps.efael.messenger = {
      enable = lib.mkEnableOption "devopsuzb's guide book";

      domain = lib.mkOption {
        type = lib.types.str;
        default = "efael.uz";
        description = "Domain name to host website under for.";
      };

      alias = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["www.efael.uz" "efael.net" "www.efael.net"];
        description = "Additional domains to associate with efael's website";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.efael.website = {
      inherit (cfg) enable;
      proxy = {
        proxy = "nginx";
        inherit (cfg) enable domain alias;
      };
    };

    services.nginx.virtualHosts = {
      "${cfg.domain}" = {
        locations =
          wellKnownLocations "${cfg.domain}" // wellKnownAppleLocations "${cfg.domain}";
      };

      "chat.${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        root = pkgs.personal.fluffy-efael;
        locations."/" = {
          extraConfig = ''
            if ($request_uri ~ ^/(.*)\.html(\?|$)) {
                return 302 /$1;
            }
            try_files $uri $uri.html $uri/ =404;
          '';
        };
      };
    };
  };
}
