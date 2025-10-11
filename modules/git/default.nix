{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.kolyma.git;
in {
  options = {
    kolyma.git = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        example = "git.example.com";
        description = "Domain to which will be hosted git provider.";
      };

      mail = lib.mkOption {
        type = lib.types.path;
        description = "Path to password file containing password for smtp server.";
      };

      database = lib.mkOption {
        type = lib.types.path;
        description = "Database password file path via key manager.";
      };

      keys = {
        public = lib.mkOption {
          type = lib.types.str;
          example = "ssh-ed25519 ...";
          description = "Public ssh key for forgejo ssh.";
        };

        private = lib.mkOption {
          type = lib.types.path;
          description = "Path to private ssh key for forgejo ssh";
        };
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "gitea";
        example = "forgejo";
        description = "User for running forgejo instance";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "gitea";
        example = "forgejo";
        description = "User's group for running forgejo instance";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."forgejo/ssh/id_forgejo.pub" = {
      inherit (cfg) user;
      mode = "600";
      text = cfg.keys.public;
    };

    # anubis to defend against LLM scrapers
    services.anubis.instances.git.settings.TARGET = with config.services.forgejo.settings.server; "http://${HTTP_ADDR}:${toString HTTP_PORT}";

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;

      extraConfig = ''
        access_log /var/log/nginx/${cfg.domain}-access.log;
        error_log /var/log/nginx/${cfg.domain}-error.log;
      '';

      locations."/user/login" = {
        priority = 100;
        extraConfig = ''
          return 302 /user/oauth2/keycloak;
        '';
      };

      locations."/" = {
        priority = 200;
        proxyPass = "http://unix:${config.services.anubis.instances.git.settings.BIND}";
        extraConfig = ''
          client_max_body_size 1G;
        '';
      };
    };

    users.users.${cfg.user} = {
      home = "/var/lib/forgejo";
      useDefaultShell = true;
      group = cfg.group;
      isSystemUser = true;
    };

    users.groups.${cfg.group} = {};

    # Expose SSH port only for forgejo SSH
    networking.firewall.interfaces.eth0.allowedTCPPorts = [2223];
    networking.firewall.extraCommands = ''
      iptables -t nat -i eth0 -I PREROUTING -p tcp --dport 22 -j REDIRECT --to-ports 2223
      ip6tables -t nat -i eth0 -I PREROUTING -p tcp --dport 22 -j REDIRECT --to-ports 2223
    '';

    services.forgejo = {
      enable = true;
      package = pkgs.forgejo-lts;
      inherit (cfg) user group;
      database = {
        type = "postgres";
        passwordFile = cfg.database;
        name = "gitea";
        user = cfg.user;
      };
      stateDir = "/var/lib/forgejo";
      lfs.enable = true;
      secrets.mailer.PASSWD = cfg.mail;
      settings = {
        DEFAULT.APP_NAME = "floss.uz git server";

        server = {
          ROOT_URL = "https://${cfg.domain}";
          DOMAIN = cfg.domain;
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3000;
          START_SSH_SERVER = true;
          SSH_LISTEN_PORT = 2223;
          SSH_SERVER_HOST_KEYS = "${cfg.keys.private}";
        };

        log.LEVEL = "Warn";

        mailer = {
          ENABLED = true;
          PROTOCOL = "smtps";
          SMTP_ADDR = "mail.floss.uz";
          SMTP_PORT = 465;
          FROM = ''"floss.uz git server" <admin@floss.uz>'';
          USER = "admin@floss.uz";
        };

        "repository.signing" = {
          SIGNING_KEY = "default";
          MERGES = "always";
        };

        openid = {
          ENABLE_OPENID_SIGNIN = true;
          ENABLE_OPENID_SIGNUP = true;
        };

        service = {
          # uncomment after initial deployment, first user is admin user
          # required to setup SSO (oauth openid-connect, keycloak auth provider)
          # ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          ENABLE_NOTIFY_MAIL = true;
          DEFAULT_KEEP_EMAIL_PRIVATE = true;
        };

        session = {
          PROVIDER = "db";
          COOKIE_SECURE = lib.mkForce true;
        };

        # https://forgejo.org/docs/latest/admin/config-cheat-sheet/#webhook-webhook
        webhook = {
          ALLOWED_HOST_LIST = "loopback,external,*.${cfg.domain}";
        };

        # See https://forgejo.org/docs/latest/admin/actions/
        actions = {
          ENABLED = true;
          # In an actions workflow, when uses: does not specify an absolute URL,
          # the value of DEFAULT_ACTIONS_URL is prepended to it.
          DEFAULT_ACTIONS_URL = "https://code.forgejo.org";
        };

        # https://forgejo.org/docs/next/admin/recommendations/#securitylogin_remember_days
        security = {
          LOGIN_REMEMBER_DAYS = 365;
        };

        # See https://docs.gitea.com/administration/config-cheat-sheet#migrations-migrations
        migrations = {
          # This allows migrations from the same forgejo instance
          ALLOW_LOCALNETWORKS = true;
        };

        # https://forgejo.org/docs/next/admin/config-cheat-sheet/#indexer-indexer
        indexer = {
          REPO_INDEXER_ENABLED = true;
          REPO_INDEXER_PATH = "indexers/repos.bleve";
          MAX_FILE_SIZE = 1048576;
          REPO_INDEXER_EXCLUDE = "resources/bin/**";
        };
      };
    };

    # See: https://docs.gitea.io/en-us/signing/#installing-and-generating-a-gpg-key-for-gitea
    # Required for gitea server side gpg signatures
    # configured/setup manually in:
    # /var/lib/gitea/data/home/.gitconfig
    # /var/lib/gitea/data/home/.gnupg/
    # sudo su gitea
    # export GNUPGHOME=/var/lib/gitea/data/home/.gnupg
    # gpg --quick-gen-key 'floss.uz gitea <admin@floss.uz>' ed25519
    # TODO: implement declarative GPG key generation and
    # gitea gitconfig
    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
    # Required to make gpg work without a graphical environment?
    # otherwise generating a new gpg key fails with this error:
    # gpg: agent_genkey failed: No pinentry
    # see: https://github.com/NixOS/nixpkgs/issues/97861#issuecomment-827951675
    environment.variables = {
      GPG_TTY = "$(tty)";
    };
  };
}
