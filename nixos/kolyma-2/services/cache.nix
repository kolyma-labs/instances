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
}
