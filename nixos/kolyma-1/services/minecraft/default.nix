{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  version = "1.21.3";
  server = lib.replaceStrings [ "." ] [ "_" ] "paper-${version}";
in
{
  imports = [ inputs.minecraft.nixosModules.minecraft-servers ];

  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers = {
      slave = {
        enable = true;
        openFirewall = true;
        package = pkgs.paperServers.${server};
        jvmOpts = "-Xms12288M -Xmx12288M -XX:+UseG1GC -XX:ParallelGCThreads=4 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";

        serverProperties = {
          server-port = 25565;
          difficulty = 3;
          gamemode = 0;
          max-players = 50;
          motd = "\\u00A7f\\u00A7lWelcome to Orzklv's Server\\u00A7r\\n\\u00A7lMore at\:\\u00A7r \\u00A7nhttps\://slave.uz";
          white-list = true;
          enable-rcon = false;
        };

        whitelist = {
          ORZKLV = "3e220001-9544-48bb-8fd0-ca7139727207";
          Overlord77_ = "d2976424-f364-4343-85ab-819a54058d2f";
          BronnzyLegit = "ee0babea-2c7e-4184-9546-4aa0f62db2ef";
          VODIYLIK = "ff179f82-7960-4f63-8137-8251fbd13e59";
        };

        symlinks = with pkgs; {
          "plugins" = linkFarmFromDrvs "plugins" (
            builtins.attrValues {
              BlueMap = fetchurl {
                url = "https://cdn.modrinth.com/data/swbUV1cr/versions/Ap3wfaNh/bluemap-5.5-spigot.jar";
                sha512 = "f21b72760545389403d3f13b0b85b95ec20ca63b01f4b369c797a816b6d14d945b13babc0ce8098a3f3243c0a28efcd907149ed7201462f9a115894fba4e3804";
              };
            }
          );

          "plugins/BlueMap" = ./plugins/BlueMap;
        };
      };
    };
  };
}
