{
  pkgs ? let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [];},
  # pre-commit-hooks,
  pre-commit-check,
  ...
}:
pkgs.stdenv.mkDerivation {
  name = "instances";

  nativeBuildInputs = with pkgs; [
    git
    nixd
    sops
    statix
    deadnix
    alejandra
  ];

  buildInputs = pre-commit-check.enabledPackages;

  NIX_CONFIG = "extra-experimental-features = nix-command flakes";

  shellHook = ''
    ${pre-commit-check.shellHook}
  '';
}
