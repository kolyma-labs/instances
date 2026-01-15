{ outputs, ... }:
{
  imports = [
    # Top level abstractions
    outputs.nixosModules.web

    # Per app preconfigured abstractions
    # outputs.nixosModules.apps.khakimovs-website
  ];

  # Kolyma services
  kolyma = {
    # https://ns5.kolyma.uz
    www = {
      enable = true;
      instance = 5;
    };

    # *://*
    # apps = {
    #   # https://*.khakimovs.uz
    #   khakimovs = {
    #     # https://khakimovs.uz
    #     website.enable = true;
    #   };
    # };
  };
}
