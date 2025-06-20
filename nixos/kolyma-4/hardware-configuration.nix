{
  config,
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

  # Bootloader shits
  boot = {
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];

    initrd = {
      kernelModules = [];
      availableKernelModules = [
        "uhci_hcd"
        "ehci_pci"
        "ata_piix"
        "hpsa"
        "hpilo"
        "usb_storage"
        "sd_mod"
        "sr_mod"
      ];
    };

    bios = {
      enable = true;
      # Use if you're going with msdos table
      # devices = ["/dev/sda"];
    };
  };

  # Use DHCP (router will handle static behaviour)
  networking.useDHCP = lib.mkDefault true;

  # Platform specific configurations
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
