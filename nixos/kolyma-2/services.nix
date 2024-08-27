{ config
, lib
, pkgs
, outputs
, ...
}: {
  # Deployed Services
  imports = [
    outputs.serverModules.bind
    outputs.serverModules.caddy.kolyma-2
    outputs.serverModules.container.kolyma-2
  ];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "slave";
    zones = [
      # Personal Space
      "orzklv.uz"
      "kolyma.uz"
      "katsuki.moe"

      # Not that personal
      "khakimovs.uz"
      "dumba.uz"

      # Projects
      "cxsmxs.space"
      "floss.uz"
      "rust-lang.uz"
      "osmon-lang.uz"
      "xinux.uz"
      "haskell.uz"
      "minecraft.uz"
    ];
    masters = [ "5.9.66.12" ];
  };
}
