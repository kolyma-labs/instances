{outputs, ...}: {
  imports = [
    # Top level abstractions
    outputs.nixosModules.web
    outputs.nixosModules.bind
    outputs.nixosModules.nextcloud
  ];

  # Kolyma services
  kolyma = {
    # Web Server & Proxy
    www = {
      enable = true;
      instance = 4;
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "slave";
    };

    nextcloud.enable = true;
  };
}
