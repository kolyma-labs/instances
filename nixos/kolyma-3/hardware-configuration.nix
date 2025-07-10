{
  inputs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    # Disko partitioning
    inputs.disko.nixosModules.disko
    ./disk-configuration.nix

    # Not available hardware modules
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelModules = [];
    extraModulePackages = [];

    initrd = {
      kernelModules = ["nvme"];
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
      ];
    };

    bios = {
      enable = true;
      uefi = true;
      raided = true;
      mirrors = [
        "/dev/nvme0n1"
        "/dev/nvme1n1"
      ];
    };
  };

  network = {
    enable = true;

    ipv4 = {
      enable = true;
      address = "37.27.66.50";
    };

    ipv6 = {
      enable = true;
      address = "2a01:4f9:3081:33a6::";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
