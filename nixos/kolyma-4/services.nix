{ config
, lib
, pkgs
, outputs
, ...
}: {
  # Deployed Services
  imports = [
    outputs.serverModules.caddy.kolyma-4
    outputs.serverModules.container.kolyma-4
  ];
}
