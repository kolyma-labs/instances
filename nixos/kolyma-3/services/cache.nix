{
  inputs,
  config,
  pkgs,
  ...
}: let
  account = "ncps";
in {
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/ncps.nix"
  ];

  sops.secrets = {
    "nix-serve/private" = {
      owner = account;
    };
  };

  services.ncps = {
    enable = true;
    package = pkgs.unstable.ncps;

    upstream = {
      caches = [
        "https://cache.nixos.org"
      ];
      publicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    cache = {
      maxSize = "100G";
      hostName = "cache.kolyma.uz";
      lru = {
        schedule = "0 2 * * *";
        scheduleTimeZone = "Asia/Tashkent";
      };
    };
  };

  services.www.hosts = {
    "cache.kolyma.uz" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:8501
      '';
    };
  };
}
