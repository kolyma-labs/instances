{
  outputs,
  config,
  ...
}: let
  secret-management = {
    owner = config.kolyma.runners.user;
    sopsFile = ../../secrets/runners.yaml;
  };
in {
  imports = [
    outputs.nixosModules.bind
    outputs.nixosModules.runner
    outputs.nixosModules.web
  ];

  sops.secrets = {
    "github/kolyma" = secret-management;
    "github/uzinfocom" = secret-management;
    "github/floss" = secret-management;
    "github/floss-community" = secret-management;
    "github/xinux" = secret-management;
    "github/rust-lang" = secret-management;
    "github/efael" = secret-management;
    "github/bleur" = secret-management;
    "github/uzbek" = secret-management;
  };

  # Kolyma services
  kolyma = {
    # Web Server & Proxy
    www = {
      enable = true;
      instance = 3;
      cdn = {
        "cdn.xinux.uz" = {
          path = "/srv/xinux";
          mode = "browse";
          extra = ''
            autoindex_format json;
          '';
        };
      };
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "slave";
    };

    runners = {
      enable = true;
      instances = [
        {
          name = "Default";
          url = "https://github.com/kolyma-labs";
          token = config.sops.secrets."github/kolyma".path;
          type = "github";
        }
        {
          name = "Uzinfocom";
          url = "https://github.com/uzinfocom-org";
          token = config.sops.secrets."github/uzinfocom".path;
          type = "github";
        }
        {
          name = "Floss";
          url = "https://github.com/floss-uz";
          token = config.sops.secrets."github/floss".path;
          type = "github";
        }
        {
          name = "Floss-Community";
          url = "https://github.com/floss-uz-community";
          token = config.sops.secrets."github/floss-community".path;
          type = "github";
        }
        {
          name = "Xinux";
          url = "https://github.com/xinux-org";
          token = config.sops.secrets."github/xinux".path;
          type = "github";
        }
        {
          name = "Rust";
          url = "https://github.com/rust-lang-uz";
          token = config.sops.secrets."github/rust-lang".path;
          type = "github";
        }
        {
          name = "Efael";
          url = "https://github.com/efael";
          token = config.sops.secrets."github/efael".path;
          type = "github";
        }
        {
          name = "Bleur";
          url = "https://github.com/bleur-org";
          token = config.sops.secrets."github/bleur".path;
          type = "github";
        }
        {
          name = "Uzbek-Net";
          url = "https://github.com/uzbek-net";
          token = config.sops.secrets."github/uzbek".path;
          type = "github";
        }
      ];
    };
  };
}
