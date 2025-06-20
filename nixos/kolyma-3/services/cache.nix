{config, ...}: let
  account = "nix-serve";
in {
  sops.secrets = {
    "nix-serve/private" = {
      owner = account;
    };
  };

  users.users.${account} = {
    description = "Nix Serve user";
    isSystemUser = true;
    group = account;
  };

  users.groups.${account} = {};

  # Enable binary cache server in 5000 port
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.sops.secrets."nix-serve/private".path;
  };

  services.www.hosts = {
    "cache.xinux.uz" = {
      addSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:5000";
        proxyWebsockets = true;
        extraConfig = "proxy_ssl_server_name on;";
      };
    };
  };
}
