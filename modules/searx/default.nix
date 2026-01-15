{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kolyma.search;
  vHostDomain = "search.${cfg.domain}";
in
{
  options = {
    kolyma.search = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether to deploy the self hosted search engine.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        default = "floss.uz";
        example = "exmaple.com";
        description = "Domain to associate search engine with.";
      };
    };
  };

  config = {
    # age.secrets.searx-environment = {
    #   file = "${flake.self}/secrets/searx-environment.age";
    #   mode = "600";
    # };

    services.nginx.virtualHosts.${vHostDomain} = {
      enableACME = true;
      forceSSL = true;

      extraConfig = ''
        access_log /var/log/nginx/${vHostDomain}-access.log;
        error_log /var/log/nginx/${vHostDomain}-error.log;
      '';

      locations."/".extraConfig = ''
        uwsgi_pass unix:/run/searx/searx.sock;
      '';
    };

    users.users.nginx.extraGroups = [ "searx" ];

    services.searx = {
      enable = true;
      package = pkgs.searxng;
      configureUwsgi = true;

      uwsgiConfig = {
        disable-logging = true;
        socket = "/run/searx/searx.sock";
        chmod-socket = "660";
      };

      # environmentFile = config.age.secrets.searx-environment.path;

      settings = {
        use_default_settings = true;

        server = {
          base_url = "https://search.${cfg.domain}";
          secret_key = "@SEARX_SECRET_KEY@";
        };

        general = {
          debug = false;
          instance_name = "search.${cfg.domain}";
          # privacypolicy_url = config.pub-solar-os.privacyPolicyUrl;
          # use true to use your own donation page written in searx/info/en/donate.md
          # use false to disable the donation link
          donation_url = false;
          # mailto:contact@example.com
          contact_url = false;
          enable_metrics = false;
        };

        search = {
          # Existing autocomplete backends: "dbpedia", "duckduckgo", "google", "yandex", "mwmbl",
          # "seznam", "startpage", "swisscows", "qwant", "wikipedia" - leave blank to turn it off
          # by default.
          autocomplete = "duckduckgo";
          # minimun characters to type before autocompleter starts
          autocomplete_min = 4;
        };

        engine = [
          {
            engine = "startpage";
            disabled = false;
          }
          {
            engine = "yahoo";
            disabled = false;
          }
          {
            engine = "tagesschau";
            disabled = false;
          }
        ];

        ui = {
          # query_in_title: When true, the result page's titles contains the query
          # it decreases the privacy, since the browser can records the page titles.
          query_in_title = false;
          # infinite_scroll: When true, automatically loads the next page when scrolling to bottom of the current page.
          infinite_scroll = true;
        };
      };
    };
  };
}
