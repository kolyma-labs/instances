{ lib }:
let
  autoModules =
    {
      path ? ../modules,
    }:
    builtins.readDir path
    |> builtins.attrNames
    |> map (x: {
      name = x;
      value = import (path + "/${x}");
    })
    |> builtins.listToAttrs;

  loadModules =
    path:
    builtins.readDir path
    |> builtins.attrNames
    |> builtins.filter (m: m != "default.nix")
    |> builtins.filter (m: m != "readme.md")
    |> builtins.map (m: path + "/${m}");
in
{
  inherit autoModules loadModules;
}
