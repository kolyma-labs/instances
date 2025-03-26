{
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Global variables
  version = "1.21.1";
in {
  imports = [inputs.minecraft.nixosModules.minecraft-servers];

  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers = {
      sabine = let
        server = lib.replaceStrings ["."] ["_"] "paper-${version}";
      in {
        enable = true;
        openFirewall = true;
        package = pkgs.paperServers.${server};
        jvmOpts = "-Xms12288M -Xmx12288M -XX:+UseG1GC -XX:ParallelGCThreads=4 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";

        serverProperties = {
          server-port = 25565;
          difficulty = 3;
          online-mode = false;
          gamemode = 0;
          max-players = 100;
          motd = "\\u00A7f\\u00A7lWelcome to Game Station's Server\\u00A7r\\n\\u00A7lMore at\:\\u00A7r \\u00A7nhttps\://sabine.uz";
          white-list = false;
          enable-rcon = true;
          "rcon.port" = 25575;
          "rcon.password" = "#rconPassword#";
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
          # "server-icon.png" = ./server-icon.png;
        };
      };
    };
  };
}
