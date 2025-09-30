{...}: {
  options = {};

  config = {
    documentation.nixos = {
      enable = true;
      checkRedirects = true;
      includeAllModules = true;
    };
  };
}
