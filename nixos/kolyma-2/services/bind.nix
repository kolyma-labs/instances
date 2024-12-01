{ outputs, ... }:
{
  imports = [ outputs.nixosModules.bind ];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "slave";
    zones = [
      # Personal Space
      "orzklv.uz"
      "kolyma.uz"
      "katsuki.moe"
      "gulag.uz"
      "khakimovs.uz"

      # Projects
      "slave.uz"
      "floss.uz"
      "sabine.uz"
      "rust-lang.uz"
      "osmon-lang.uz"
      "xinux.uz"
      "haskell.uz"
      "niggerlicious.uz"
    ];
    masters = [ "5.9.66.12" ];
  };
}
