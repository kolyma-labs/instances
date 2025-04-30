{
  config,
  inputs,
  ...
}: let
  management = {
    owner = config.services.tarmoqchi.user;
  };
in {
  imports = [inputs.tarmoqchi.nixosModules.tarmoqchi];

  sops.secrets = {
    "tarmoqchi/database" = management;
    "tarmoqchi/github/id" = management;
    "tarmoqchi/github/secret" = management;
  };

  # Enable tarmoqchi server
  services.tarmoqchi = {
    enable = true;
    port = 9876;

    proxy-reverse = {
      enable = true;
      domain = "tarmoqchi.uz";
      proxy = "nginx";
    };

    github = {
      id = config.sops.secrets."tarmoqchi/github/id".path;
      secret = config.sops.secrets."tarmoqchi/github/secret".path;
    };

    database = {
      passwordFile = config.sops.secrets."tarmoqchi/database".path;
    };
  };
}
