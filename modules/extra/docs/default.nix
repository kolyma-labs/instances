{...}: {
  options = {};

  config = {
    documentation.nixos = {
      # Disable HTML documentation for NixOS modules, can cause issues with module overrides
      enable = false;

      # Fails for not providing custom doc rendering
      checkRedirects = false;

      # Why not gamble?
      includeAllModules = true;
    };
  };
}
