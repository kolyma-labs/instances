{outputs, ...}: {
  imports = [outputs.nixosModules.bind];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "master";
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
    slaves = ["65.109.74.214"];
  };
}
