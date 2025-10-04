{
  outputs,
  config,
  ...
}: {
  imports = [
    outputs.nixosModules.web
    outputs.nixosModules.auth
    outputs.nixosModules.bind
  ];

  sops.secrets = {
    "auth/database" = {
      sopsFile = ../../secrets/floss.yaml;
    };
  };

  # Kolyma services
  kolyma = {
    # Web Server & Proxy
    www = {
      enable = true;
      instance = 1;
      alias = ["kolyma.uz"];
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "master";
    };

    # Keycloak Management
    auth = {
      enable = true;
      password = config.sops.secrets."auth/database".path;
    };
  };
}
