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

      settings = {
        # Enforce latest ssh protocol
        Protocol = 2;
        # Forbid root login through SSH.
        PermitRootLogin = "no";
        # Use keys only. Remove if you want to SSH using password (not recommended)
        PasswordAuthentication = false;
        # Disable interactive auth
        KbdInteractiveAuthentication = false;
        # Explicitly state auth methods
        AuthenticationMethods = "publickey";
        # Unecessary hole in my ass
        UsePAM = false;
        # Fuck anyone else out there
        MaxSessions = 2;
        # Get more GPUs, brokey!
        Ciphers = ["aes256-ctr" "aes192-ctr" "aes128-ctr"];
        # Pre-defined list of acceptable keys
        programs.ssh.pubkeyAcceptedKeyTypes = ["ssh-ed25519" "ssh-rsa"];
      };
    };

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
