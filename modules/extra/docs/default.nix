{...}: {
  options = {};

  config = {
    documentation.nixos = {
      enable = true;
      checkRedirects = false;
      includeAllModules = true;
    };
  };
}
