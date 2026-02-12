{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.kolyma.www;

  default =
    if (cfg.domain == "") then
      {
        "default_server" = {
          default = true;
          root = "${pkgs.personal.gate}/www";
        };
      }
    else
      {
        ${cfg.domain} = {
          default = true;
          forceSSL = true;
          enableACME = true;
          serverAliases = cfg.alias;
          root = "${pkgs.personal.gate}/www";
        };
      };

  mkCDN = builtins.mapAttrs (
    name: value: {
      addSSL = true;
      enableACME = true;
      root = value.path;
      serverAliases = value.alias;
      locations = lib.mkIf (value.mode == "static") {
        "/".extraConfig = ''
          try_files $uri $uri/ $uri.html =404;

          ${lib.optionalString (value.extra != null) ''
            ${value.extra}
          ''}
        '';
      };

      extraConfig = ''
        ${lib.optionalString (value.mode == "browse") ''
          autoindex on;
        ''}

        ${lib.optionalString (value.extra != null) ''
          ${value.extra}
        ''}
      '';
    }
  );
in
{
  options = {
    kolyma.www = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the web server/proxy.";
      };

      instance = lib.mkOption {
        type = lib.types.number;
        example = 1;
        description = "Identifier signature of the current instance.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        default = "ns${toString cfg.instance}.kolyma.uz";
        description = "The default signature domain of instance.";
      };

      alias = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of extra aliases to host.";
      };

      hosts = lib.mkOption {
        type = with lib.types; attrsOf (submodule anything);
        default = { };
        description = "List of hosted service instances.";
      };

      cdn = lib.mkOption {
        type = with lib.types; attrsOf (submodule lib.kotypes.cdn);
        default = { };
        description = "List of cdn services hosted in this instance.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !((builtins.length cfg.alias) != 0 && cfg.domain == "");
        message = "don't set aliases if there's no primary domain yet";
      }
    ];

    # Configure Nginx
    services.nginx = {
      # Enable the Nginx web server
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      # Default virtual host
      virtualHosts = lib.mkMerge [
        default
        cfg.hosts
        (mkCDN cfg.cdn)
        (mkCDN {
          "cdn${toString cfg.instance}.kolyma.uz" = {
            path = "/srv";
            mode = "browse";
            alias = [ ];
            extra = "
              add_before_body /.html/top.html;
              add_after_body /.html/bot.html;
              autoindex_localtime on;
              autoindex_exact_size on;
              sub_filter '<html>' '';
              sub_filter '<head><title>Index of $uri</title></head>' '';
              sub_filter '<body bgcolor=\"white\">' '';
              sub_filter '</body>' '';
              sub_filter '</html>' '';
              sub_filter_once on;
            ";
          };
        })
      ];
    };

    # Accepting ACME Terms
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "admin@kolyma.uz";
      };
    };

    # Ensure the firewall allows HTTP and HTTPS traffic
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [
      80
      443
    ];

    system.activationScripts.nginxTheme =
      let
        theme = pkgs.fetchzip {
          url = "https://github.com/uzinfocom-org/autoindex/archive/refs/heads/main.zip";
          hash = "sha256-bBsL22+mlMuFNzaEVxPq0Bg/f9IXELJEVzgWMBqGfF8=";
        };
      in
      {
        text = ''
          #!/bin/sh
          cp -R ${theme}/.html /srv
        '';
      };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [ orzklv ];
  };
}
