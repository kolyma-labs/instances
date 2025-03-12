{outputs, ...}: {
  imports = [outputs.nixosModules.bind];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "slave";
    zones = [
      # Personal Space
      "orzklv.uz"
      "kolyma.uz"
      "gulag.uz"
      "khakimovs.uz"

      # Projects
      "shar.af"
      "slave.uz"
      "floss.uz"
      "rust-lang.uz"
      "osmon-lang.uz"
      "xinux.uz"
      "haskell.uz"
      "nix-darwin.org"
      "niggerlicious.uz"
    ];
    masters = ["167.235.96.40"];
  };
}
