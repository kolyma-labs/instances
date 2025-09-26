{outputs, ...}: {
  imports = [outputs.nixosModules.bind];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "slave";

    masters = [
      # Kolyma GK-1
      "37.27.67.190"
      "2a01:4f9:3081:3518::2"
    ];
  };
}
