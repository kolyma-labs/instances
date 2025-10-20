{outputs, ...}: {
  imports = [
    # Top level abstractions
    outputs.nixosModules.web
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
