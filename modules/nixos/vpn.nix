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

      secret = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        description = lib.mdDoc ''
          Path to generated key for OpenVPN. Generate via `openvpn --genkey secret output.key`.
        '';
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
      ifconfig 10.8.0.1 10.8.0.2
      secret ${cfg.secret}
      port ${toString cfg.port}

      cipher AES-256-CBC
      auth-nocache

      comp-lzo
      keepalive 10 60
      ping-timer-rem
      persist-tun
      persist-key
    '';

    environment.etc."openvpn/output.ovpn" = {
      text = ''
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
        secret [inline]

      '';
      mode = "600";
    };

    system.activationScripts.openvpn-addkey = ''
      f="/etc/openvpn/output.ovpn"
      if ! grep -q '<secret>' $f; then
        echo "appending secret key"
        echo "<secret>" >> $f
        cat ${cfg.secret} >> $f
        echo "</secret>" >> $f
      fi
    '';
  };
}
