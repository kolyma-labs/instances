{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.kolyma.openvpn;
  internal-interface = "tun0";
  private-address = "10.8.0.0";
in {
  options = {
    kolyma.openvpn = {
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
      # server side secrets
      "vpn/openvpn/ca" = {
        format = "binary";
        sopsFile = ../../../secrets/vpn/openvpn/ca.hell;
      };
      "vpn/openvpn/key" = {
        format = "binary";
        sopsFile = ../../../secrets/vpn/openvpn/key.hell;
      };
      "vpn/openvpn/crt" = {
        format = "binary";
        sopsFile = ../../../secrets/vpn/openvpn/crt.hell;
      };
      "vpn/openvpn/dh" = {
        format = "binary";
        sopsFile = ../../../secrets/vpn/openvpn/dh.hell;
      };
      "vpn/openvpn/tls" = {
        format = "binary";
        sopsFile = ../../../secrets/vpn/openvpn/tls.hell;
      };
      # client side secrets
      "vpn/openvpn/ccrt" = {
        format = "binary";
        sopsFile = ../../../secrets/vpn/openvpn/ccrt.hell;
      };
      "vpn/openvpn/ckey" = {
        format = "binary";
        sopsFile = ../../../secrets/vpn/openvpn/ckey.hell;
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
        trustedInterfaces = [internal-interface];
        allowedUDPPorts = [cfg.port];
        checkReversePath = "loose";
      };
    };

    services.openvpn.servers.kolyma.config = ''
      dev ${internal-interface}
      proto udp
      port ${toString cfg.port}

      server ${private-address} 255.255.255.0
      topology subnet

      push "redirect-gateway def1"
      push "dhcp-option DNS 1.1.1.1"
      push "dhcp-option DNS 1.0.0.1"

      tls-server

      cipher AES-256-CBC

      auth-nocache
      keepalive 60 180
      ping-timer-rem
      persist-tun
      persist-key

      management localhost 5001

      key ${config.sops.secrets."vpn/openvpn/key".path}
      cert ${config.sops.secrets."vpn/openvpn/crt".path}
      ca ${config.sops.secrets."vpn/openvpn/ca".path}
      dh ${config.sops.secrets."vpn/openvpn/dh".path}
      tls-auth ${config.sops.secrets."vpn/openvpn/tls".path} 0
    '';

    boot.kernel.sysctl."net.ipv4.conf.all.src_valid_mark" = 1;
  };

  meta = {
    doc = ./openvpn.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
