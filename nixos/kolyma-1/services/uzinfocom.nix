{inputs, ...}: let
  base = "uzinfocom.uz";
in {
  imports = [
    inputs.uzinfocom-website.nixosModules.server
    inputs.uzinfocom-taggis.nixosModules.server
  ];

  # Enable website module
  services.uzinfocom.website = {
    enable = true;
    port = 8659;
    host = "127.0.0.1";

    proxy = {
      enable = true;
      proxy = "nginx";
      domain = "oss.${base}";
    };
  };

  # Enable website module
  services.uzinfocom.taggis = {
    enable = true;
    port = 8658;
    host = "127.0.0.1";

    proxy = {
      enable = true;
      proxy = "nginx";
      domain = "link.${base}";
    };
  };
}
