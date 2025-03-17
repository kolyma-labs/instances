{
  config,
  inputs,
  ...
}: let
  domain_name = "floss.uz";
  user_name = "orzklv";
  secure_token = "niggerlicious";
in {
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [8448];
      allowedUDPPorts = [53];
    };
  };

  matrix-conduit = {
    enable = true;
    settings.global = {
      address = "127.0.0.1";
      allow_registration = true;
      registration_token = "${secure_token}";
      database_backend = "rocksdb";
      port = 6167;
      server_name = "${domain_name}";
    };
  };

  services.www.hosts = {
    "${domain_name}" = {
      extraConfig = ''
        reverse_proxy /_matrix/* 127.0.0.1:6167

        redir https://www.{host}{uri}
      '';
    };
  };
}
