# Fallback validation point of all modules
{ ... }:
{
  # List all modules here to be included on config
  imports = [
    # Bind nameserver service for hosting personal domains
    ./bind.nix

    # GitLab instance & Git server
    ./gitlab.nix

    # Mail server
    ./mail.nix

    # Minecraft server configurations
    ./minecraft.nix

    # Web server & proxy virtual hosts via caddy
    ./www.nix
  ];
}
