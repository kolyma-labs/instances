{ lib }:
let
  # WARNING!
  # Becomes impure when opath provided
  attrSystem =
    {
      list,
      inputs,
      outputs,
      opath ? ../.,
    }:
    let
      # Generate absolute path to the configuration
      path = alias: opath + "/hosts/${alias}/configuration.nix";

      #   Name  =                Value
      # "Lorem" = orzklv.lib.config.makeSystem "station";
      system = attr: {
        inherit (attr) name;
        value = makeSystem {
          inherit inputs outputs;
          path = path attr.alias;
        };
      };
      # [
      #   { name = "Lorem", value = config }
      #   { name = "Ipsum", value = config }
      # ]
      ref = map system list;
    in
    lib.listToAttrs ref;

  # WARNING!
  # Becomes impure when opath provided
  mapSystem =
    {
      list,
      inputs,
      outputs,
      opath ? ../.,
    }:
    let
      # Generate absolute path to the configuration
      path = name: opath + "/hosts/${lib.toLower name}/configuration.nix";

      #   Name  =                Value
      # "Lorem" = orzklv.lib.config.makeSystem "station";
      system = name: {
        inherit name;
        value = makeSystem {
          inherit inputs outputs;
          path = path name;
        };
      };

      # [
      #   { name = "Lorem", value = config }
      #   { name = "Ipsum", value = config }
      # ]
      ref = lib.map system list;
    in
    lib.listToAttrs ref;

  makeSystem =
    {
      path,
      inputs,
      outputs,
    }:
    let
      attr = {
        specialArgs = {
          inherit (outputs) lib;
          inherit inputs outputs;
        };
        modules = [
          # > Our main nixos configuration file <
          path
        ];
      };
    in
    lib.nixosSystem attr;
in
{
  inherit attrSystem mapSystem makeSystem;
}
