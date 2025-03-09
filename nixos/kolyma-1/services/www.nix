{
  outputs,
  pkgs,
  ...
}: {
  imports = [outputs.nixosModules.caddy];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = ["ns1.kolyma.uz"];
    hosts = {
      "khakimovs.uz" = {
        serverAliases = ["www.khakimovs.uz"];
        extraConfig = ''
          root * ${pkgs.personal.khakimovs}/www
          file_server
        '';
      };

      "flac.orzklv.uz" = {
        extraConfig = ''
          basic_auth {
          damn $2a$14$AG1UgXWK.f4KlLn7eNvDuOBc.xuueQ9ZO1.Gt3D/fS4ejERGSmoUy
          }

          root * /srv/flac
          file_server browse
        '';
      };

      "tiesto.orzklv.uz" = {
        extraConfig = ''
          root * /srv/flac/Tiesto
          file_server browse
        '';
      };

      "niggerlicious.uz" = {
        serverAliases = ["www.niggerlicious.uz"];
        extraConfig = ''
          reverse_proxy 127.0.0.1:8100
        '';
      };
    };
  };
}
