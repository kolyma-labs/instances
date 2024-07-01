{
  config,
  pkgs,
  lib,
  ...
}: let
  linux = with pkgs; [
    # Add new packages here
    docker-compose
    pinentry
  ];

  globals = with pkgs; [
    # Downloader
    aria

    # Developer Mode
    gh
    jq
    wget
    zola
    gitui
    zellij
    netcat
    direnv
    git-lfs
    gitoxide
    cargo-update

    # Environment
    fd
    bat
    btop
    eza
    figlet
    gping
    hyperfine
    lolcat
    fastfetch
    onefetch
    procs
    ripgrep
    tealdeer
    topgrade

    # Tech
    rustup

    # Media encode & decode
    ffmpeg
    libheif

    # Anime
    crunchy-cli

    # GPG Signing
    gnupg

    # Selfmade programs
    fp
  ];
in {
  config = {
    # Packages to be installed on my machine
    home.packages = globals ++ linux;
  };
}
