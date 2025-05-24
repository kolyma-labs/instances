{inputs, ...}: let
  domain = "link.uzinfocom.uz";
in {
  imports = [inputs.taggis.nixosModules.server];

  # Enable website module
  services.uzinfocom.taggis = {
    enable = true;
    port = 8658;
    host = "127.0.0.1";

    proxy = {
      inherit domain;
      enable = true;
      proxy = "nginx";
    };
  };
}
