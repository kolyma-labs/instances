{ outputs, ... }: {
  imports = [
    outputs.serverModules.caddy
  ];

  # Enable web server & proxy
  services.www = {
    enable = true;

    hosts = {
      "cdn.kolyma.uz" = {
        extraConfig = ''
          root * /srv/cdn
          file_server browse
        '';
      };
    };
  };
}
