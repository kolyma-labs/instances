# Fallback validation point of all modules
{...}: {
  # List all modules here to be included on config
  imports = [
    # Bind nameserver service for hosting personal domains
    ./bind.nix

    # List of docker instances hosted in this machine
    ./container.nix

    # Minecraft server configurations
    ./minecraft

    # GitHub Runner configurations
    ./runner.nix

    # Git server for storing personal git projects
    ./gitlab.nix

    # Web server & proxy virtual hosts via caddy
    ./www.nix

    # Streaming service self hosted
    ./streaming.nix

    # Matrix server hosting
    ./matrix

    # Uzinfocom related infra
    ./uzinfocom.nix

    # Mail server for the team
    ./mail.nix
  ];
}
