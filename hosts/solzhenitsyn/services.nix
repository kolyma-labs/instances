{outputs, ...}: {
  imports = [
    outputs.nixosModules.web
    outputs.nixosModules.bind
    outputs.nixosModules.gate
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

    gate = {
      enable = true;
    };
  };
}
