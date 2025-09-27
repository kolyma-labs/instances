# Original from: uzinfocom-org/pkgs
# Credits to: @bahrom04, @let-rec
{lib}: let
  mkUser = i: {
    name =
      if i ? username
      then i.username
      else builtins.throw "oh-ow, somebody didn't define their username";

    value = {
      isNormalUser = true;
      description = i.description or "";

      extraGroups = [
        "wheel"
        "admins"
        "docker"
      ];

      openssh.authorizedKeys.keys = let
        byKeys = i.keys or [];

        byUrl =
          lib.optionals
          (i ? keysUrl
            && i ? sha256
            && i.keysUrl != null
            && i.sha256 != null)
          (lib.strings.splitString "\n"
            (builtins.readFile (builtins.fetchurl {
              url = "${i.keysUrl}";
              sha256 = "${i.sha256}";
            })));
      in
        byKeys ++ byUrl;
    };
  };
  mkUsers = users: {
    # mapped users
    users.users = builtins.listToAttrs (builtins.map mkUser users);
  };
in {inherit mkUsers;}
