{outputs, ...}: {
  imports = [
    outputs.nixosModules.web
    outputs.nixosModules.bind
  ];

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
  };
}
