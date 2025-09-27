# Fallback validation point of all modules
{...}: {
  # List all modules here to be included on config
  imports = [
    # List of docker instances hosted in this machine
    ./container.nix

    # Haskell Zulip portal
    ./haskell.nix

    # Mail server
    ./mail.nix

    # Xinux deployment & services
    ./xinux.nix

    # Rustina bot from Rust Uzbekistan
    ./rustina.nix

    # Matrix self-hosted server
    ./matrix

    # Local mastodon self-hosted server
    ./mastodon.nix

    # Floss Uzbekistan's website
    ./floss-www.nix

    # DevOps Jorney's website
    ./devops-journey.nix

    # Tarmoqchi HTTP tunneling
    ./tarmoqchi.nix

    # GitHub runners
    ./runner.nix

    # VPN server
    ./vpn.nix
  ];

  config = {
    kolyma = {
      # Web Server & Proxy
      www = {
        enable = true;
        domain = "ns6.kolyma.uz";
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
