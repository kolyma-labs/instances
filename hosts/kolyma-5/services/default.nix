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
  ];

  config = {
    # Kolyma services
    kolyma = {
      # Web Server & Proxy
      www = {
        enable = true;
        domain = "ns5.kolyma.uz";
        anubis = true;
      };

      # Nameserver
      nameserver = {
        enable = true;
        type = "slave";

        masters = [
          # Kolyma GK-1
          "37.27.67.190"
          "2a01:4f9:3081:3518::2"
        ];
      };
    };
  };
}
