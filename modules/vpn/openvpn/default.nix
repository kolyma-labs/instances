{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.openvpn;
  internal-interface = "tun0";
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

      domain = lib.mkOption {
        type = lib.types.str;
        default = "kolyma.uz";
        description = "The default domain of instance.";
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
      };
    };

    services.openvpn.servers.kolyma.config = ''
      dev ${internal-interface}
      proto udp
      port ${toString cfg.port}
      server 10.100.0.0 255.255.255.0
      topology subnet

      push "redirect-gateway def1"
      push "dhcp-option DNS 1.1.1.1"
      push "dhcp-option DNS 1.0.0.1"
      push "route ${config.kolyma.network.ipv4} 255.255.255.255 net_gateway"
      tls-server

      cipher AES-256-CBC
      auth-nocache

      keepalive 10 60
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

    environment.etc = {
      "openvpn/output.ovpn" = {
        text = ''
          client
          dev tun
          remote "${cfg.domain}"
          port ${toString cfg.port}
          nobind
          cipher AES-256-CBC
          comp-lzo adaptive
          resolv-retry infinite
          persist-key
          persist-tun
          tls-client
          key-direction 1

        '';
        mode = "600";
      };
    };

    system.activationScripts.openvpn-addkey = ''
      f="/etc/openvpn/output.ovpn"

      if ! grep -q '<ca>' $f; then
        echo "appending secret key"
        echo "<ca>" >> $f
        cat ${config.sops.secrets."vpn/openvpn/ca".path} >> $f
        echo "</ca>" >> $f
      fi

      if ! grep -q '<key>' $f; then
        echo "appending secret key"
        echo "<key>" >> $f
        cat ${config.sops.secrets."vpn/openvpn/ckey".path} >> $f
        echo "</key>" >> $f
      fi

      if ! grep -q '<cert>' $f; then
        echo "appending secret key"
        echo "<cert>" >> $flib.mdDoc
        cat ${config.sops.secrets."vpn/openvpn/ccrt".path} >> $f
        echo "</cert>" >> $f
      fi

      if ! grep -q '<tls-auth>' $f; then
        echo "appending secret key"
        echo "<tls-auth>" >> $f
        cat ${config.sops.secrets."vpn/openvpn/tls".path} >> $f
        echo "</tls-auth>" >> $f
      fi
    '';
  };

  meta = {
    doc = ./openvpn.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
