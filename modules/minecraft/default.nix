{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.kolyma.minecraft;

  version = "1.21.10";
in {
  imports = [
    inputs.minecraft.nixosModules.minecraft-servers
  ];

  options = {
    kolyma.minecraft = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether to deploy minecraft server in the server.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 25565;
        example = 6969;
        description = "Port to expose server from.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-servers = let
      server = lib.replaceStrings ["."] ["_"] "vanilla-${version}";
    in {
      eula = true;
      enable = true;

      servers.floss = {
        enable = true;
        jvmOpts = "-Xms8196M -Xmx8196M -XX:+UseG1GC";
        package = pkgs.vanillaServers.${server};

        serverProperties = {
          server-port = cfg.port;
          difficulty = 3;
          gamemode = 0;
          max-players = 100;
          motd = "\\u00A7f\\u00A7lWelcome to Floss Uzbekistan's Server\\u00A7r\\n\\u00A7lFor more at\:\\u00A7r \\u00A7nhttps\://niggerlicious.uz";
          white-list = true;
          enable-rcon = true;
          "rcon.port" = 25575;
          "rcon.password" = "F1st1ng15300Buck!?";
        };

        whitelist = import ./players.nix;

        symlinks = {
          "server-icon.png" = ./server-icon.png;
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [cfg.port];
      allowedUDPPorts = [cfg.port];
    };
  };
}
