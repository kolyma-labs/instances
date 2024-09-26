{ outputs, ... }: {
  imports = [
    outputs.serverModules.caddy
  ];

  # Enable web server & proxy
  services.www = {
    enable = true;

    hosts = {
      "mail.kolyma.uz" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8460
        '';
      };

      "git.kolyma.uz" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8450
        '';
      };
    };
  };
}
