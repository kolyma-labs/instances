# Fallback validation point of all modules
{...}: {
  # List all modules here to be included on config
  imports = [
    # Bind nameserver service for hosting personal domains
    ./bind.nix

    # Binary cache server
    ./cache.nix

    # List of docker instances hosted in this machine
    ./container.nix

    # GitHub Runner configurations
    ./runner.nix

    # Web server & proxy virtual hosts via caddy
    ./www.nix

    # Mail server
    ./mail.nix

    # Xinux deployment & services
    ./xinux.nix

    # Rustina bot from Rust Uzbekistan
    ./rustina.nix

    # Minecraft server configurations
    ./minecraft

    # Matrix self-hosted server
    ./matrix.nix

    # Local mastodon self-hosted server
    ./mastodon.nix

    # Floss Uzbekistan's website
    ./floss-www.nix

    # DevOps Jorney's website
    ./devops-journey.nix
  ];
}
