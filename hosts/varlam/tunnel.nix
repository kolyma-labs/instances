{config, ...}: {
  networking.firewall.allowedUDPPorts = [51820];

  sops.secrets = {
    "vpn/varlam" = {
      format = "binary";
      sopsFile = ../../secrets/vpn/varlam.hell;
    };
  };

  networking.wireguard.interfaces = {
    wg-ssh = {
      mtu = 1300;
      listenPort = 51820;
      ips = ["10.100.0.11/32"];
      privateKeyFile = config.sops.secrets."vpn/varlam".path;
      peers = [
        {
          persistentKeepalive = 25;
          endpoint = "213.230.122.228:666";
          publicKey = "oDSqZC1ki2LtCF3pU7Zp2QhrXiHC4pV6o2ljaufyyxA=";
          allowedIPs = ["10.10.1.0/24" "10.100.0.0/24"];
        }
      ];
    };
  };

  services.openssh.listenAddresses = [
    {
      addr = "10.100.0.11";
      port = 22;
    }
  ];
}
