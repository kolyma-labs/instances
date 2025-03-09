{
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Global variables
  version = "1.21.4";
in {
  imports = [inputs.minecraft.nixosModules.minecraft-servers];

  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers = {
      slave = let
        server = lib.replaceStrings ["."] ["_"] "paper-${version}";
      in {
        enable = true;
        openFirewall = true;
        package = pkgs.paperServers.${server};
        jvmOpts = "-Xms12288M -Xmx12288M -XX:+UseG1GC -XX:ParallelGCThreads=4 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";

        serverProperties = {
          server-port = 25565;
          difficulty = 3;
          gamemode = 0;
          max-players = 50;
          motd = "\\u00A7f\\u00A7lWelcome to Orzklv's Server\\u00A7r\\n\\u00A7lMore at\:\\u00A7r \\u00A7nhttps\://niggerlicious.uz";
          white-list = true;
          enable-rcon = true;
          "rcon.port" = 25575;
          "rcon.password" = "F1st1ng15300Buck!?";
        };

        whitelist = {
          Orzklv = "3e220001-9544-48bb-8fd0-ca7139727207";
          Vodiyl = "ff179f82-7960-4f63-8137-8251fbd13e59";
          AniSar = "48ed1b8a-ed65-4321-aae7-76734fe8cc27";
          OwOssi = "14f4fba3-bd65-48d3-b212-2e77383c1b1d";
          Thelis = "2c3a8eb7-921b-4e4a-ba60-c5e3a83d941f";
          Overlo = "d2976424-f364-4343-85ab-819a54058d2f";
          Bronnz = "ee0babea-2c7e-4184-9546-4aa0f62db2ef";
          Shakhz = "1c786ec6-0f65-4448-9ecf-ab53b75bf867";
          Nixxer = "8fdd80ef-c294-432d-b381-e43353a3db27";
          NurMuh = "13831a9f-9d7c-47b7-8865-d089ac7d6e1f";
        };

        symlinks = with pkgs; {
          "plugins/BlueMap" = ./plugins/BlueMap;
          "plugins/bluemap-spigot.jar" = fetchurl {
            url = "https://cdn.modrinth.com/data/swbUV1cr/versions/wBnzat7x/bluemap-5.7-spigot.jar";
            hash = "sha256-lTeyxzJNQeMdu1IVdovNMtgn77jRIhSybLdMbTkf2Ww=";
          };
          "plugins/Chunky-Bukkit.jar" = fetchurl {
            url = "https://cdn.modrinth.com/data/fALzjamp/versions/ytBhnGfO/Chunky-Bukkit-1.4.28.jar";
            hash = "sha256-lTeyxzJNQeMdu1IVdovNMtgn77jRIhSybLdMbTkf2Ww=";
          };
          "server-icon.png" = ./server-icon.png;
        };
      };
    };
  };
}
