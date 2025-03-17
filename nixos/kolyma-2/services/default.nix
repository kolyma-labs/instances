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

    # Xinux deployment & services
    ./xinux.nix

    # Rustina bot from Rust Uzbekistan
    ./rustina.nix

    # Matrix self-hosted server
    # ./matrix.nix
  ];
}
