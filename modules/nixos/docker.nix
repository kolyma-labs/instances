{ config
, lib
, pkgs
, inputs
, ...
}: {
  config = {
    virtualisation = {
      docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune = {
          enable = true;
          dates = "daily";
        };
      };
      oci-containers = {
        backend = "docker";
      };
    };
  };
}
