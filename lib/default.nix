{lib}: {
  # User Lists
  camps = import ../gulag/camps.nix {inherit lib;};
  labors = import ../gulag/labors.nix {inherit lib;};

  # Helpful functions & generators
  users = import ./users.nix {inherit lib;};
  instances = import ./instances.nix {inherit lib;};
}
