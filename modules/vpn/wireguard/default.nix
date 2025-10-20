{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.kolyma.wireguard;
  internal-interface = "wg0";
  ipv4-address = "10.100.0.1/24";
  ipv6-address = "fd00:fae:fae:fae:fae:1::/96";
in {
  options = {
    kolyma.wireguard = {
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
      "vpn/wireguard/private" = {
        format = "binary";
        sopsFile = ../../../secrets/vpn/wireguard/private.hell;
      };
    };

    # sudo systemctl start nat
    networking = {
      nat = {
        enable = true;
        enableIPv6 = true;
        externalInterface = "eth0";
        internalInterfaces = [internal-interface];
      };

      firewall.allowedUDPPorts = [cfg.port];
    };

    networking.wireguard = {
      enable = true;

      interfaces = {
        # "wg0" is the network interface name. You can name the interface arbitrarily.
        wg0 = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = [
            ipv4-address
            ipv6-address
          ];

          # The port that WireGuard listens to. Must be accessible by the client.
          listenPort = cfg.port;

          # Path to the private key file.
          #
          # Note: The private key can also be included inline via the privateKey option,
          # but this makes the private key world-readable; thus, using privateKeyFile is
          # recommended.
          privateKeyFile = config.sops.secrets."vpn/wireguard/private".path;

          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${ipv4-address} -o eth0 -j MASQUERADE
            ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
            ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s ${ipv6-address} -o eth0 -j MASQUERADE
          '';

          # Undo the above
          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${ipv4-address} -o eth0 -j MASQUERADE
            ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
            ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s ${ipv6-address} -o eth0 -j MASQUERADE
          '';

          peers = [
            # List of allowed peers.
            {
              # MacBook Pro
              publicKey = "GkpZmq6M1PFn5rLdv4bzO0cfzs+nCKTePL0m+iACqmU=";
              allowedIPs = [
                "10.100.0.2/32"
              ];
            }
            {
              # iPhone 17 Pro
              publicKey = "anOorzlJBGRY9pXO3Svj1lih+1jmhodmAtpExyzjOCs=";
              allowedIPs = [
                "10.100.0.3/32"
              ];
            }
          ];
        };
      };
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
