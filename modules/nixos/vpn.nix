{
  lib,
  config,
  ...
}: let
  cfg = config.services.vpn;
  internal-interface = "tun0";
in {
  options = {
    services.vpn = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the containers service.";
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

      secrets = {
        server = {
          ca = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = lib.mdDoc ''
              Path to generated key for OpenVPN. https://forums.opto22.com/t/recommended-openvpn-server-setup-tutorial/5383/4.
            '';
          };
          key = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = lib.mdDoc ''
              Path to generated key for OpenVPN. https://forums.opto22.com/t/recommended-openvpn-server-setup-tutorial/5383/4.
            '';
          };
          cert = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = lib.mdDoc ''
              Path to generated key for OpenVPN. https://forums.opto22.com/t/recommended-openvpn-server-setup-tutorial/5383/4.
            '';
          };
          dh = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = lib.mdDoc ''
              Path to generated key for OpenVPN. Generate via `openssl dhparam -out dh.pem 2048`.
            '';
          };
          tls = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = lib.mdDoc ''
              Path to generated key for OpenVPN. Generate via `openvpn --genkey secret tls.auth`.
            '';
          };
        };
        client = {
          key = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = lib.mdDoc ''
              Path to generated key for OpenVPN. https://forums.opto22.com/t/recommended-openvpn-server-setup-tutorial/5383/4.
            '';
          };
          cert = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = lib.mdDoc ''
              Path to generated key for OpenVPN. https://forums.opto22.com/t/recommended-openvpn-server-setup-tutorial/5383/4.
            '';
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
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
      server 10.8.0.0 255.255.0.0
      push "route 10.0.0.0 255.255.0.0"
      push "redirect-gateway def1"
      port ${toString cfg.port}
      tls-server

      cipher AES-256-CBC
      auth-nocache

      comp-lzo
      keepalive 10 60
      ping-timer-rem
      persist-tun
      persist-key

      management localhost 5001

      key ${cfg.secrets.server.key}
      cert ${cfg.secrets.server.cert}
      ca ${cfg.secrets.server.ca}
      dh ${cfg.secrets.server.dh}
      tls-auth ${cfg.secrets.server.tls} 0
    '';

    environment.etc."openvpn/output.ovpn" = {
      text = ''
        client
        dev tun
        remote "${cfg.domain}"
        ifconfig 10.8.0.2 10.8.0.1
        port ${toString cfg.port}
        redirect-gateway def1

        cipher AES-256-CBC
        auth-nocache

        comp-lzo
        keepalive 10 60
        resolv-retry infinite
        nobind
        persist-key
        persist-tun
        tls-client
        key-direction 1

      '';
      mode = "600";
    };

    system.activationScripts.openvpn-addkey = ''
      f="/etc/openvpn/output.ovpn"

      if ! grep -q '<ca>' $f; then
        echo "appending secret key"
        echo "<ca>" >> $f
        cat ${cfg.secrets.server.ca} >> $f
        echo "</ca>" >> $f
      fi

      if ! grep -q '<key>' $f; then
        echo "appending secret key"
        echo "<key>" >> $f
        cat ${cfg.secrets.client.key} >> $f
        echo "</key>" >> $f
      fi

      if ! grep -q '<cert>' $f; then
        echo "appending secret key"
        echo "<cert>" >> $f
        cat ${cfg.secrets.client.cert} >> $f
        echo "</cert>" >> $f
      fi

      if ! grep -q '<tls-auth>' $f; then
        echo "appending secret key"
        echo "<tls-auth>" >> $f
        cat ${cfg.secrets.server.tls} >> $f
        echo "</tls-auth>" >> $f
      fi

    '';
  };
}
