{ outputs, ... }:
{
  imports = [ outputs.nixosModules.bind ];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "master";
    zones = [
      # Personal Space
      "orzklv.uz"
      "kolyma.uz"
      "katsuki.moe"
      "gulag.uz"

      # Not that personal
      "khakimovs.uz"
      "dumba.uz"

      # Projects
      "slave.uz"
      "floss.uz"
      "sabine.uz"
      "rust-lang.uz"
      "osmon-lang.uz"
      "xinux.uz"
      "haskell.uz"
      "niggerlicious.uz"
      "misskey.uz"
    ];
    slaves = [ "65.109.61.35" ];
  };
}
