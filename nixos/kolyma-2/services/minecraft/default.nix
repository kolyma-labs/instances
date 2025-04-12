{
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Global variables
  version = "1.19.2";
in {
  imports = [inputs.minecraft.nixosModules.minecraft-servers];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/var/lib/minecraft";
    servers = {
      mod = let
        server = lib.replaceStrings ["."] ["_"] "fabric-${version}";
      in {
        enable = true;
        openFirewall = true;
        package = pkgs.fabricServers.${server}.override {loaderVersion = "0.14.6";};
        jvmOpts = "-Xms12288M -Xmx12288M -XX:+UseG1GC -XX:ParallelGCThreads=4 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";

        serverProperties = {
          server-port = 25565;
          difficulty = 3;
          gamemode = 0;
          max-players = 50;
          online-mode = false;
          motd = "\\u00A7f\\u00A7lWelcome to Sabine's Modded Server\\u00A7r\\n\\u00A7lMore at\:\\u00A7r \\u00A7nhttps\://mod.sabine.uz";
          white-list = false;
          enable-rcon = false;
          "rcon.port" = 25575;
          "rcon.password" = "F1st1ng15300Buck!?";
        };

        symlinks = with pkgs; {
          "mods/fabric-api-0.75.1-1.19.2.jar" = fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/6iOab8Tp/fabric-api-0.75.1%2B1.19.2.jar";
            hash = "sha256-yhJ+HJlSb7N0//+OKJtPSLcoAec54In1uwfAtp3jWsQ=";
          };
          "mods/BlueMap-3.13-fabric-1.19.jar" = fetchurl {
            url = "https://cdn.modrinth.com/data/swbUV1cr/versions/51epxpKG/BlueMap-3.13-fabric-1.19.jar";
            hash = "sha256-5+0KhV8a6oa1AqHP3dnoHpfuan/9AG5NLuSxXNbwc3I=";
          };
          "server-icon.png" = ./server-icon.png;
        };
      };
    };
  };
}
