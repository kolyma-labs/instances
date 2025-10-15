{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.kolyma.vpn;
  internal-interface = "wg0";
in {
  options = {
    kolyma.vpn = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the open vpn service.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 6666;
        description = "Port to be served for.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "vpn/private" = {
        format = "binary";
        sopsFile = ../../secrets/vpn/private.hell;
      };
    };

    # sudo systemctl start nat
    networking = {
      nat = {
        enable = true;
        externalInterface = "eth0";
        internalInterfaces = [internal-interface];
      };

      firewall = {
        allowedUDPPorts = [cfg.port];
        trustedInterfaces = [internal-interface];
      };
    };

    networking.wireguard.interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      wg0 = {
        # Determines the IP address and subnet of the server's end of the tunnel interface.
        ips = ["10.100.0.1/24"];

        # The port that WireGuard listens to. Must be accessible by the client.
        listenPort = cfg.port;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT;
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables  -D FORWARD -i wg0 -j ACCEPT;
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
        '';

        # Path to the private key file.
        #
        # Note: The private key can also be included inline via the privateKey option,
        # but this makes the private key world-readable; thus, using privateKeyFile is
        # recommended.
        privateKeyFile = config.sops.secrets."vpn/private".path;

        peers = [
          # List of allowed peers.
          {
            # MacBook Pro
            publicKey = "slu/vv1RJe3RKxSn2P94i0A6IuIwBfbHFuFi5VpjnTk=";
            allowedIPs = ["10.100.0.2/32"];
          }
          {
            # iPhone 17 Pro
            publicKey = "anOorzlJBGRY9pXO3Svj1lih+1jmhodmAtpExyzjOCs=";
            allowedIPs = ["10.100.0.3/32"];
          }
        ];
      };
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
