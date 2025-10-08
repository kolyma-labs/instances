{
  stdenvNoCC,
  jq,
  element-themes,
}:
stdenvNoCC.mkDerivation {
  src = element-themes;
  name = "element-themes";
  nativeBuildInputs = [jq];
  buildPhase = ''
    find "$src" -name '*.json' -print0 | xargs -0 jq -s '.' > $out
  '';
}
