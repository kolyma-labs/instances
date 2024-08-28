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
    device = "/dev/disk/by-uuid/a5ccf292-63ec-4104-a57d-6ac4d497f3ff";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/86D4-469D";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/4320a760-6776-4071-a75e-77d3be13be35"; }
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
