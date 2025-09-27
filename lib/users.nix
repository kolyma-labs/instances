# Original from: uzinfocom-org/pkgs
# Credits to: @bahrom04, @let-rec
{lib}: let
  mkUser = i: {
    name =
      i.username or
      builtins.throw "oh-ow, somebody didn't define their username";

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
          ((builtins.hasAttr i.keysUrl) && (builtins.hasAttr i.sha256))
          (lib.strings.splitString
            "\n" (builtins.readFile (builtins.fetchurl {
              url = "${i.githubKeysUrl}";
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
