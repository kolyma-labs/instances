#!/usr/bin/env just --working-directory ./ --justfile

default:
  @just --list

#     _   ___      ____  _____
#    / | / (_)  __/ __ \/ ___/
#   /  |/ / / |/_/ / / /\__ \
#  / /|  / />  </ /_/ /___/ /
# /_/ |_/_/_/|_|\____//____/

nx-update-local:
    sudo nixos-rebuild switch --flake . --upgrade

nx-update-repo:
    sudo nixos-rebuild switch --flake github:orzklv/nix --upgrade

#     ____             __
#    / __ \___  ____  / /___  __  __
#   / / / / _ \/ __ \/ / __ \/ / / /
#  / /_/ /  __/ /_/ / / /_/ / /_/ /
# /_____/\___/ .___/_/\____/\__, /
#           /_/            /____/

# Specify targets to update nixos for
NIXOS_TARGETS := "kolyma-1 kolyma-2"

deploy-nixos:
    for target in $(echo {{NIXOS_TARGETS}}); do \
        echo Updating target: $target; \
        sudo nixos-rebuild --flake github:orzklv/nix --target-host $target --build-host localhost switch; \
    done

#   ______            __
#  /_  __/___  ____  / /____
#   / / / __ \/ __ \/ / ___/
#  / / / /_/ / /_/ / (__  )
# /_/  \____/\____/_/____/

format:
    nix fmt

test:
    nix flake check --all-systems --show-trace
