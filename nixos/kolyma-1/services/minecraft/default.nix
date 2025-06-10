{
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Global variables
  version = "1.21.5";
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
        jvmOpts = "-Xms24576M -Xmx24576M -XX:+UseG1GC -XX:ParallelGCThreads=4 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";

        serverProperties = {
          server-port = 25565;
          difficulty = 3;
          gamemode = 0;
          max-players = 50;
          motd = "\\u00A7f\\u00A7lWelcome to Uzinfocom Open Source's Server\\u00A7r\\n\\u00A7lMore at\:\\u00A7r \\u00A7nhttps\://niggerlicious.uz";
          white-list = true;
          enable-rcon = false;
          "rcon.port" = 25575;
          "rcon.password" = "F1st1ng15300Buck!?";
        };

        whitelist = {
          Orzklv = "3e220001-9544-48bb-8fd0-ca7139727207";
          OwOssi = "14f4fba3-bd65-48d3-b212-2e77383c1b1d";
          Shakhz = "1c786ec6-0f65-4448-9ecf-ab53b75bf867";
          Nixxer = "8fdd80ef-c294-432d-b381-e43353a3db27";
          Bahrom04 = "15f652bf-33f9-4a08-aaf1-acc6a019c504";
          Thelis = "2c3a8eb7-921b-4e4a-ba60-c5e3a83d941f";
          Domirando = "5432bfe3-2685-4223-ba25-81600dd041bc";
        };

        symlinks = with pkgs; {
          "plugins/BlueMap" = ./plugins/BlueMap;
          "plugins/bluemap-spigot.jar" = fetchurl {
            url = "https://cdn.modrinth.com/data/swbUV1cr/versions/wBnzat7x/bluemap-5.7-spigot.jar";
            hash = "sha256-mZ00IyPVe4GD1C6+B47MA9X/P+MQZ5dpaOX/hEec0d0=";
          };
          "plugins/Chunky-Bukkit.jar" = fetchurl {
            url = "https://cdn.modrinth.com/data/fALzjamp/versions/mhLtMoLk/Chunky-Fabric-1.4.36.jar  ";
            hash = "sha256-vLttrvBeviawvhMk2ZcjN5KecT4Qy+os4FEqMPYB77U=";
          };
          "server-icon.png" = ./server-icon.png;
        };
      };
    };
  };
}
