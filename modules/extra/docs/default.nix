{...}: {
  options = {};

  config = {
    documentation.nixos = {
      checkRedirects = false;
      includeAllModules = true;
    };
  };
}
