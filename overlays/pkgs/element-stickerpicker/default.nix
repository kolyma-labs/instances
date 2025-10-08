{
  stdenvNoCC,
  element-stickers,
  maunium-stickerpicker,
}:
stdenvNoCC.mkDerivation {
  src = maunium-stickerpicker;
  name = "element-stickers";
  buildPhase = ''
    mv web $out/
    cp ${element-stickers}/uploaded-packs/*.json $out/packs/
    cp -r ${element-stickers}/uploaded-packs/thumbnails $out/packs/
  '';
}
