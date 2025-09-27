# Fallback validation point of all modules
{...}: {
  # List all modules here to be included on config
  imports = [
    # List of docker instances hosted in this machine
    ./container.nix

    # Git server for storing personal git projects
    ./gitlab.nix

    # Khakimov's website
    ./khakimovs.nix

    # Matrix server hosting
    ./matrix

    # Uzinfocom related infra
    ./uzinfocom.nix

    # Mail server for the team
    ./mail.nix

    # VPN server
    ./vpn.nix
  ];
}
