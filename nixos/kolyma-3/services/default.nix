# Fallback validation point of all modules
{...}: {
  # List all modules here to be included on config
  imports = [
    # Web server & proxy virtual hosts via caddy
    ./www.nix

    # GitHub Runner configurations
    ./runner.nix

    # Tarmoqchi HTTP tunneling
    ./tarmoqchi.nix

    # Uzinfocom related infra
    ./uzinfocom.nix
  ];
}
