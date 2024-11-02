{ inputs, config, pkgs, ... }:
let
  secret-management = {
    owner = "misskey"; # config.users.users.misskey.name;
  };
in
{
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/misskey.nix"
  ];

  sops.secrets = {
    "misskey/database/password" = secret-management;
    "misskey/redis/password" = secret-management;
    "misskey/meilisearch/password" = secret-management;
  };

  services.misskey = {
    enable = true;
    package = pkgs.unstable.misskey;

    reverseProxy = {
      enable = true;
      ssl = true;
      host = "misskey.uz";
      webserver.caddy = { };
    };

    redis.passwordFile = config.sops.secrets."misskey/redis/password".path;
    meilisearch.keyFile = config.sops.secrets."misskey/meilisearch/password".path;
    database.passwordFile = config.sops.secrets."misskey/database/password".path;

    settings = {
      port = 9001;
    };
  };

  # services.www.hosts = {
  #   "misskey.uz" = {
  #     extraConfig = ''
  #       reverse_proxy http://127.0.01:${config.services.misskey.settings.port}
  #     '';
  #   };
  # };
}
