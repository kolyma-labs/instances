# Fallback validation point of all modules
{...}: {
  # List all modules here to be included on config
  imports = [
    # Bind nameserver service for hosting personal domains
    ./bind.nix

    # List of docker instances hosted in this machine
    ./container.nix

    # Web server & proxy virtual hosts via caddy
    ./www.nix

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
}
