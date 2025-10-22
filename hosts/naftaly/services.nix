{outputs, ...}: {
  imports = [
    # Top level abstractions
    outputs.nixosModules.web
    outputs.nixosModules.bind
    outputs.nixosModules.minecraft
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

    # Nextcloud server
    nextcloud.enable = true;

    # Minecraft server
    minecraft.enable = true;
  };
}
