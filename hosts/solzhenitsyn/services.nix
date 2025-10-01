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
      domain = "ns2.kolyma.uz";
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "slave";
    };
  };
}
