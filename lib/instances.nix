{lib}: let
  # WARNING!
  # Becomes impure when opath provided
  attrSystem = {
    list,
    inputs,
    outputs,
    opath ? ../.,
    type ? "nixos",
  }: let
    # Generate absolute path to the configuration
    path = alias: opath + "/${type}/${alias}/configuration.nix";

    #   Name  =                Value
    # "Lorem" = orzklv.lib.config.makeSystem "station";
    system = attr: {
      inherit (attr) name;
      value = makeSystem {
        inherit inputs outputs type;
        path = path attr.alias;
      };
    };
    # [
    #   { name = "Lorem", value = config }
    #   { name = "Ipsum", value = config }
    # ]
    map = lib.map system list;
  in
    lib.listToAttrs map;

  # WARNING!
  # Becomes impure when opath provided
  mapSystem = {
    list,
    inputs,
    outputs,
    opath ? ../.,
    type ? "nixos",
  }: let
    # Generate absolute path to the configuration
    path = name: opath + "/${type}/${lib.toLower name}/configuration.nix";

    #   Name  =                Value
    # "Lorem" = orzklv.lib.config.makeSystem "station";
    system = name: {
      inherit name;
      value = makeSystem {
        inherit inputs outputs type;
        path = path name;
      };
    };

    # [
    #   { name = "Lorem", value = config }
    #   { name = "Ipsum", value = config }
    # ]
    map = lib.map system list;
  in
    lib.listToAttrs map;

  makeSystem = {
    path,
    inputs,
    outputs,
    type ? "nixos",
  }: let
    attr = {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        # > Our main nixos configuration file <
        path
      ];
    };

    fn =
      if type == "darwin"
      then inputs.nix-darwin.lib.darwinSystem
      else lib.nixosSystem;
  in
    fn attr;
in {
  inherit attrSystem mapSystem makeSystem;
}
