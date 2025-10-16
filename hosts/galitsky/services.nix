{outputs, ...}: {
  imports = [
    # Top level abstractions
    outputs.nixosModules.web
    outputs.nixosModules.bind
  ];

  # Kolyma services
  kolyma = {
    # Web Server & Proxy
    www = {
      enable = true;
      instance = 5;
    };
  };
}
