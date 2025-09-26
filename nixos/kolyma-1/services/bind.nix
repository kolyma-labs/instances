{outputs, ...}: {
  imports = [outputs.nixosModules.bind];

  # Enable Nameserver hosting
  services.nameserver = {
    enable = true;
    type = "master";

    slaves = [
      # Kolyma GK-2
      "37.27.60.37"
      "2a01:4f9:3081:2e04::2"

      # Kolyma GK-5
      "167.235.96.40"
      "2a01:4f8:2190:2914::2"

      # Kolyma GK-6
      "65.109.74.214"
      "2a01:4f9:3071:31ce::2"
    ];
  };
}
