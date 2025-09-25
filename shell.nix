{
  pkgs ? let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [];},
  pre-commit-check,
  ...
}:
pkgs.stdenv.mkDerivation {
  name = "instances";

  # Initial dependencies
  nativeBuildInputs = with pkgs; [
    git
    nixd
    sops
    statix
    deadnix
    alejandra

    easyrsa
    openssl
  ];

  # Runtime dependencies
  buildInputs = pre-commit-check.enabledPackages;

  # Bootstrapping commands
  shellHook = ''
    # Initiate git hooks
    ${pre-commit-check.shellHook}

    # Fetch latest changes
    git pull
  '';

  # Nix related configurations
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
}
