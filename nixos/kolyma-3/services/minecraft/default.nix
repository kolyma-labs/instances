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
        jvmOpts = "-Xms8192M -Xmx8192M -XX:+UseG1GC -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";

        serverProperties = {
          server-port = 25565;
          difficulty = 3;
          gamemode = 0;
          max-players = 50;
          motd = "\\u00A7f\\u00A7lWelcome to Orzklv's Personal Server\\u00A7r\\n\\u00A7lMore at\:\\u00A7r \\u00A7nhttps\://map.slave.uz";
          white-list = true;
          enable-rcon = false;
          "rcon.port" = 25575;
          "rcon.password" = "F1st1ng15300Buck!?";
        };

        whitelist = {
          Orzklv = "3e220001-9544-48bb-8fd0-ca7139727207";
          OwOssi = "14f4fba3-bd65-48d3-b212-2e77383c1b1d";
          Nixxer = "8fdd80ef-c294-432d-b381-e43353a3db27";
        };

        symlinks = with pkgs; {
          "plugins/BlueMap" = ./plugins/BlueMap;
          "plugins/bluemap-spigot.jar" = fetchurl {
            url = "https://cdn.modrinth.com/data/swbUV1cr/versions/wBnzat7x/bluemap-5.7-spigot.jar";
            hash = "sha256-mZ00IyPVe4GD1C6+B47MA9X/P+MQZ5dpaOX/hEec0d0=";
          };
          "plugins/Chunky-Bukkit.jar" = fetchurl {
            url = "https://cdn.modrinth.com/data/fALzjamp/versions/ytBhnGfO/Chunky-Bukkit-1.4.28.jar";
            hash = "sha256-G6MwUA+JUDJRkbpwvOC4PnR0k+XuCvcIJnDDXFF3oy4=";
          };
          "server-icon.png" = ./server-icon.png;
        };
      };
    };
  };
}
