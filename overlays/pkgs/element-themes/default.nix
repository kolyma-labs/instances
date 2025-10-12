{
  lib,
  stdenvNoCC,
  jq,
  element-themes,
}:
stdenvNoCC.mkDerivation {
  name = "element-themes";
  src = element-themes;
  nativeBuildInputs = [jq];

  buildPhase = ''
    find "$src" -name '*.json' -print0 | xargs -0 jq -s '.' > $out
  '';

  meta.platforms = lib.platforms.all;
}
