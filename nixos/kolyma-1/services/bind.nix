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

      # Personal Projects
      "foss.uz"
      "ecma.uz"
      "nyan.uz"
      "slave.uz"
      "xinux.uz"
      "floss.uz"
      "bleur.net"
      "gopher.uz"
      "sabine.uz"
      "haskell.uz"
      "php.org.uz"
      "uzbek.net.uz"
      "tarmoqchi.uz"
      "rust-lang.uz"
      "osmon-lang.uz"
      "trashiston.uz"
      "nix-darwin.uz"
      "niggerlicious.uz"
      "devops-journey.uz"

      # Goofy Ahh Zone
      "efael.uz"
      "efael.net"

      # Dangarus Zone
      "oss.uzinfocom.uz"
      "link.uzinfocom.uz"
    ];
  };
}
