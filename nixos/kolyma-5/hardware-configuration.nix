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
      kernelModules = [];
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "sr_mod"
      ];
    };

    bios = {
      enable = true;
      uefi = false;
    };
  };

  network = {
    enable = true;

    ipv4 = {
      enable = true;
      address = "192.168.0.2";
    };

    ipv6 = {
      enable = false;
      address = null;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
