{
  outputs,
  config,
  ...
}: let
  secret-management = {
    owner = config.kolyma.runners.user;
    sopsFile = ../../secrets/runners.yaml;
  };
in {
  imports = [
    outputs.nixosModules.web
    outputs.nixosModules.bind
    outputs.nixosModules.runner
  ];

  sops.secrets = {
    "github/xinux" = secret-management;
  };

  # Kolyma services
  kolyma = {
    # Web Server & Proxy
    www = {
      enable = true;
      domain = "ns3.kolyma.uz";
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "slave";
    };

    runners = {
      enable = true;
      instances = [
        {
          name = "Xinux";
          url = "https://github.com/xinux-org";
          token = config.sops.secrets."github/xinux".path;
          type = "github";
        }
      ];
    };
  };
}
