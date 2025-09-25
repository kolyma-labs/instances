{outputs, ...}: {
  imports = [outputs.nixosModules.bind];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "slave";

    masters = [
      "167.235.96.40"
      "2a01:4f8:2190:2914::"
    ];

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
      "uzberk.uz"
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
      "uchar.uz"

      # Dangarus Zone
      "oss.uzinfocom.uz"
      "link.uzinfocom.uz"
    ];
  };
}
