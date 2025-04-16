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
      "slave.uz"
      "foss.uz"
      "floss.uz"
      "ecma.uz"
      "nyan.uz"
      "rust-lang.uz"
      "osmon-lang.uz"
      "xinux.uz"
      "haskell.uz"
      "sabine.uz"
      "devops-journey.uz"
      "trashiston.uz"
      "niggerlicious.uz"
    ];
    slaves = ["65.109.74.214"];
  };
}
