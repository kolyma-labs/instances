# Fallback validation point of all modules
{ ... }:
{
  # List all modules here to be included on config
  imports = [
    # Bind nameserver service for hosting personal domains
    ./bind.nix

    # List of docker instances hosted in this machine
    ./container.nix

    # Web server & proxy virtual hosts via caddy
    ./www.nix

    # GitHub Runner configurations
    ./runner.nix
  ];
}
