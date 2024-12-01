{ outputs, pkgs, ... }:
{
  imports = [ outputs.nixosModules.caddy ];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [ "ns5.kolyma.uz" ];
    hosts = {
      "khakimovs.uz" = {
        serverAliases = [ "www.khakimovs.uz" ];
        extraConfig = ''
          root * ${pkgs.personal.khakimovs}/www
          file_server
        '';
      };
    };
  };
}
