# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/ wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  ssh = import ./ssh.nix;
  zsh = import ./zsh.nix;
  boot = import ./boot.nix;
  data = import ./data.nix;
  users = import ./users;
  network = import ./network.nix;
  nixpkgs = import ./nixpkgs.nix;
}
