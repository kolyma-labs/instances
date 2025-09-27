{
  config,
  outputs,
  ...
}: {
  imports = [outputs.nixosModules.vpn];

  sops.secrets = {
    server-ca = {
      format = "binary";
      sopsFile = ../../../secrets/network/server/ca.hell;
    };
    server-cert = {
      format = "binary";
      sopsFile = ../../../secrets/network/server/cert.hell;
    };
    server-key = {
      format = "binary";
      sopsFile = ../../../secrets/network/server/key.hell;
    };
    server-dh = {
      format = "binary";
      sopsFile = ../../../secrets/network/server/dh.hell;
    };
    server-tls = {
      format = "binary";
      sopsFile = ../../../secrets/network/server/tls.hell;
    };

    client-key = {
      format = "binary";
      sopsFile = ../../../secrets/network/client/key.hell;
    };
    client-cert = {
      format = "binary";
      sopsFile = ../../../secrets/network/client/cert.hell;
    };
  };

  kolyma.vpn.openvpn = {
    enable = true;
    domain = "ns2.kolyma.uz";
    secrets = {
      client = {
      };

      server = {
        ca = config.sops.secrets.server-ca.path;
        key = config.sops.secrets.server-key.path;
        cert = config.sops.secrets.server-cert.path;
        dh = config.sops.secrets.server-dh.path;
        tls = config.sops.secrets.server-tls.path;
      };

      client = {
        key = config.sops.secrets.client-key.path;
        cert = config.sops.secrets.client-cert.path;
      };
    };
  };
}
