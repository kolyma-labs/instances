{outputs, ...}: {
  imports = [
    outputs.nixosModules.web
    outputs.nixosModules.bind
  ];

  # Kolyma services
  kolyma = {
    # Enable web server & proxy
    www = {
      enable = true;
      instance = 2;
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "slave";
    };
  };
}
