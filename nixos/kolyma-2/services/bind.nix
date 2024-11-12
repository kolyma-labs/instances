{ outputs, ... }: {
  imports = [
    outputs.nixosModules.bind
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
      "gulag.uz"

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
      "niggerlicious.uz"
      "misskey.uz"
    ];
    masters = [ "5.9.66.12" ];
  };
}
