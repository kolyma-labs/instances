# Fallback validation point of all modules
{...}: {
  # List all modules here to be included on config
  imports = [
    # Web server & proxy virtual hosts via caddy
    ./www.nix

    # Minecraft server configurations
    ./minecraft
  ];
}
