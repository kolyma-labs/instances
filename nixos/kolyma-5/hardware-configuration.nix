{
  config,
  inputs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    # Disko partitioning
    # inputs.disko.nixosModules.disko
    # ./disk-configuration.nix

    # Not available hardware modules
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

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
      devices = ["/dev/sda"];
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [
    {device = "/dev/disk/by-label/NIXSWAP";}
  ];

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
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
