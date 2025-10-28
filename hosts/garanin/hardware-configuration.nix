{
  config,
  inputs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-configuration.nix

    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      kernelModules = [
        "nvme"
        "kvm-intel"
      ];

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
  };

  kolyma.boot = {
    enable = true;
  };

  networking.useDHCP = lib.mkForce true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
