{
  config,
  outputs,
  ...
}: {
  imports = [outputs.nixosModules.vpn];

  sops.secrets.vpn = {
    format = "binary";
    sopsFile = ../../../secrets/network.hell;
  };

  services.vpn = {
    enable = true;
    domain = "ns2.kolyma.uz";
    secret = config.sops.secrets.vpn.path;
  };
}
