{ outputs, ... }:
{
  imports = [
    # Top level abstractions
    outputs.nixosModules.web
    outputs.nixosModules.bind
    outputs.nixosModules.nextcloud

    # Per app preconfigured abstractions
    outputs.nixosModules.apps.khakimovs-website
  ];

  # Kolyma services
  kolyma = {
    # https://ns4.kolyma.uz
    www = {
      enable = true;
      instance = 4;
    };

    # bind://ns4.kolyma.uz
    nameserver = {
      enable = true;
      type = "slave";
    };

    # https://cloud.floss.uz
    nextcloud.enable = true;

    # *://*
    apps = {
      # https://*.khakimovs.uz
      khakimovs = {
        # https://khakimovs.uz
        website.enable = true;
      };
    };
  };
}
