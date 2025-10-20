builtins.readDir ./.
|> builtins.attrNames
|> builtins.filter (m: m != "default.nix")
|> builtins.filter (m: m != "readme.md")
|> builtins.map (m: {
  name = m;
  value = import (./. + "/${m}");
})
|> builtins.listToAttrs
