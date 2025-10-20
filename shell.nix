{
  pkgs ? let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs-unstable.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [];},
  pre-commit-check ? import (builtins.fetchTarball "https://github.com/cachix/git-hooks.nix/tarball/master"),
  ...
}:
pkgs.stdenv.mkDerivation {
  name = "instances";

  # Initial dependencies
  nativeBuildInputs = with pkgs; [
    git
    sops

    # Latest statix
    (
      statix.overrideAttrs
      (_o: rec {
        src = fetchFromGitHub {
          owner = "oppiliappan";
          repo = "statix";
          rev = "43681f0da4bf1cc6ecd487ef0a5c6ad72e3397c7";
          hash = "sha256-LXvbkO/H+xscQsyHIo/QbNPw2EKqheuNjphdLfIZUv4=";
        };

        cargoDeps = pkgs.rustPlatform.importCargoLock {
          lockFile = src + "/Cargo.lock";
          allowBuiltinFetchGit = true;
        };
      })
    )

    nixd
    deadnix
    alejandra

    # DNS Management
    dig.dev

    # Certificate Generation
    easyrsa
    openssl

    # VPN Management
    wireguard-tools
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
  NIX_CONFIG = "extra-experimental-features = nix-command flakes pipe-operators";
}
