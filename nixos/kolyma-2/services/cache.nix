{
  config,
  inputs,
  ...
}: {
  # Enable binary cache server in 5000 port
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-priv-key.pem";
  };

  services.www.hosts = {
    "cache.xinux.uz" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:5000
      '';
    };
  };
}
