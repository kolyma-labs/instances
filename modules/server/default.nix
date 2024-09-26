# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/ wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  bind = import ./bind.nix;
  caddy = import ./caddy.nix;
  container = import ./container.nix;
}
