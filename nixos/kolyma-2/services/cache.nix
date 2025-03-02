{
  config,
  inputs,
  ...
}: {
  sops.secrets = {
    "nix-serve/private" = {
      owner = "nix-serve";
    };
  };

  # Enable binary cache server in 5000 port
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.sops.secrets."nix-serve/private".path;
  };

  services.www.hosts = {
    "cache.xinux.uz" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:5000
      '';
    };
  };
}
