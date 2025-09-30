{lib}: let
  labors =
    lib.labors or import ./labors.nix {inherit lib;};
in {
  owners = {
    members = with labors; [
      orzklv
    ];
    scope = "Owners of this gulag system.";
  };

  uzinfocom = {
    members = with labors; [
      aekinskjaldi
      bahrom04
      lambdajon
      orzklv
      shakhzod
    ];
    scope = "Employees of Uzinfocom maintaining Open Source.";
  };

  prisioners = {
    members = with labors; [
      kei
      crypton
      shakhzod
    ];
    scope = "Dearly inmates from gulag camps.";
  };
}
