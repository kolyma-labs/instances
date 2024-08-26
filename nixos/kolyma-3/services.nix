{ config
, lib
, pkgs
, outputs
, ...
}: {
  # Deployed Services
  imports = [
    outputs.serverModules.caddy.kolyma-3
    outputs.serverModules.container.kolyma-3
  ];
}
