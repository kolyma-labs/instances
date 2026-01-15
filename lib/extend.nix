# Just a convenience function that returns the given Nixpkgs standard
# library extended with the Orzklv library.
nixpkgsLib:
let
  mkGulag = import ./.;
in
nixpkgsLib.extend (
  self: super: {
    kolyma = mkGulag { lib = self; };

    # For forward compatibility.
    literalExpression = super.literalExpression or super.literalExample;
    literalDocBook = super.literalDocBook or super.literalExample;
  }
)
