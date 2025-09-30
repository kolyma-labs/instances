{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.remote;
in {
  options = {
    kolyma.remote = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable remote connection.";
      };

      motd = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show welcoming motd on login.";
      };

      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [22];
        description = ''
          Specifies on which ports the SSH daemon listens.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # This setups a SSH server. Very important if you're setting up a headless system.
    # Feel free to remove if you don't need it.
    services.openssh = {
      inherit (cfg) enable ports;

      # Use only declarative keys
      authorizedKeysInHomedir = false;

      settings = {
        # Enforce latest ssh protocol
        Protocol = 2;
        # Forbid root login through SSH.
        PermitRootLogin = "no";
        # Use keys only. Remove if you want to SSH using password (not recommended)
        PasswordAuthentication = false;
        # Disable interactive auth
        KbdInteractiveAuthentication = false;
        # Unecessary hole in my ass
        UsePAM = false;
        # Fuck anyone else out there
        MaxSessions = 2;
        # Show welcoming motd on login
        PrintMotd = true;
      };
    };

    users.motd = builtins.readFile ./motd.txt;

    # Ensure the firewall allows SSH traffic
    networking.firewall = {
      allowedTCPPorts = cfg.ports;
      allowedUDPPorts = cfg.ports;
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
