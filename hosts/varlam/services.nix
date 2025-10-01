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
      instance = 1;
      alias = ["kolyma.uz"];
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "master";
    };
  };
}
