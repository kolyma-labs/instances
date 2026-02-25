{
  outputs,
  config,
  ...
}:
let
  secret-management = {
    owner = config.kolyma.runners.user;
    sopsFile = ../../secrets/runners.yaml;
  };
in
{
  imports = [
    # Top level abstractions
    outputs.nixosModules.bind
    outputs.nixosModules.hydra
    outputs.nixosModules.runner
    outputs.nixosModules.web
  ];

  sops = {
    secrets = {
      "forgejo/kolyma" = secret-management;
      "github/floss" = secret-management;
      "github/floss-community" = secret-management;
      "github/rust-lang" = secret-management;
      "github/uzbek" = secret-management;
    };

    templates = {
      "gitea-forgejo-kolyma" = {
        owner = config.kolyma.runners.user;
        content = ''
          TOKEN=${config.sops.placeholder."forgejo/kolyma"}
        '';
      };
    };
  };

  # Kolyma services
  kolyma = {
    # https://ns3.kolyma.uz [cdn.xinux.uz,...]
    www = {
      enable = true;
      instance = 3;
    };

    # bind://ns3.kolyma.uz
    nameserver = {
      enable = true;
      type = "slave";
    };

    # https://(hydra|cache).kolyma.uz
    hydra.enable = true;
    nixpkgs.master = true;

    # * -> github.com
    runners = {
      enable = true;
      instances = [
        {
          name = "Default";
          url = "https://git.floss.uz";
          token = config.sops.templates."gitea-forgejo-kolyma".path;
          type = "forgejo";
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
          name = "Rust";
          url = "https://github.com/rust-lang-uz";
          token = config.sops.secrets."github/rust-lang".path;
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
