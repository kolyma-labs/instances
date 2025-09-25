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
      kernelModules = [
        "nvme"
        "kvm-intel"
      ];
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
      address = "37.27.60.37";
    };

    ipv6 = {
      enable = true;
      address = "2a01:4f9:3081:2e04::";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
