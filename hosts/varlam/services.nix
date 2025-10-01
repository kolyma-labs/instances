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
      domain = "ns1.kolyma.uz";
      alias = ["kolyma.uz"];
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "master";
    };
  };
}
