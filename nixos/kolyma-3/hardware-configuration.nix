{ config
, lib
, pkgs
, modulesPath
, ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" ];
  boot.initrd.kernelModules = [ "nvme" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.bios = {
    enable = true;
    uefi = true;
    raided = true;
    mirrors = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cfa68e38-a4dd-401f-9794-224a4e1dfd08";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1B12-CEDF";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/1e7187bf-7374-41d6-bf0d-4c38a51e02bd"; }
  ];

  network = {
    enable = true;

    ipv4 = {
      enable = true;
      address = "95.216.248.25";
    };

    ipv6 = {
      enable = true;
      address = "2a01:4f9:3070:322c::";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
