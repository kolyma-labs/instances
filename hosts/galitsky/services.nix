{outputs, ...}: {
  imports = [
    # Top level abstractions
    outputs.nixosModules.web
    outputs.nixosModules.vpn
  ];

  # Kolyma services
  kolyma = {
    # Web Server & Proxy
    www = {
      enable = true;
      instance = 5;
    };

    vpn.enable = true;
  };
}
