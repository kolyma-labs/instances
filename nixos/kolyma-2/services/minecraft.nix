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

    servers = {
      slave = let
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
      };
    };
  };
}
