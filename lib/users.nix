# Original from: uzinfocom-org/pkgs
# Credits to: @bahrom04, @let-rec
{ lib }:
let
  mkUser = i: {
    name = i.username or (builtins.throw "oh-ow, somebody didn't define their username");

    value = {
      isNormalUser = true;
      description = i.description or "";

      extraGroups = [
        "wheel"
        "admins"
        "docker"
      ];

      hashedPassword = i.password or "";

      openssh.authorizedKeys.keys =
        let
          byKeys = i.keys or [ ];

          byUrl = lib.optionals (i ? keysUrl && i ? sha256 && i.keysUrl != null && i.sha256 != null) (
            builtins.fetchurl {
              url = "${i.keysUrl}";
              sha256 = "${i.sha256}";
            }
            |> builtins.readFile
            |> lib.strings.splitString "\n"
          );
        in
        byKeys ++ byUrl;
    };
  };
  mkUsers = users: {
    # mapped users
    users.users = builtins.map mkUser users |> builtins.listToAttrs;
  };
in
{
  inherit mkUsers;
}
