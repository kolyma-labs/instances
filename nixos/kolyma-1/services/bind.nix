{ outputs, ... }: {
  imports = [
    outputs.nixosModules.bind
  ];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "master";
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
    ];
    slaves = [ "65.109.61.35" ];
  };
}
