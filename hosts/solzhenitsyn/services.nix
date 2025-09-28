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

      apps = [
        {
          inputs = "uzinfocom-website";
          module = "server";
          option = "uzinfocom.website";
          domain = "oss.uzinfocom.uz";
        }
      ];
    };

    # Nameserver
    nameserver = {
      enable = true;
      type = "slave";

      masters = [
        # Kolyma GK-1
        "37.27.67.190"
        "2a01:4f9:3081:3518::2"
      ];
    };
  };
}
