{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.kolyma.minecraft;

  version = "1.21.10";
in
{
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

      rcon = lib.mkOption {
        type = lib.types.port;
        default = 25575;
        example = 6969;
        description = "Port to expose server from.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-servers =
      let
        server = lib.replaceStrings [ "." ] [ "_" ] "vanilla-${version}";
      in
      {
        eula = true;
        enable = true;

        servers = {
          nigger = {
            enable = true;
            jvmOpts = "-Xms12288M -Xmx12288M -XX:+UseG1GC";
            package = pkgs.vanillaServers.${server};

            serverProperties = {
              server-port = cfg.port;
              difficulty = 3;
              gamemode = 0;
              max-players = 100;
              motd = "\\u00A7f\\u00A7lWelcome to Nigger's Server\\u00A7r\\n\\u00A7lFor more, visit\:\\u00A7r \\u00A7nhttps\://niggerlicious.uz";
              white-list = false;
              online-mode = false;
              enable-rcon = true;
              level-name = "FrozenCherry";
              level-seed = -6384763642895912697;
              "rcon.port" = cfg.rcon;
              "rcon.password" = "F1st1ng15300Buck";
            };

            # whitelist = import ./players.nix;

            symlinks = {
              "server-icon.png" = ./server-icon.png;
            };
          };

          retard = {
            enable = true;
            jvmOpts = "-Xms8196M -Xmx8196M -XX:+UseG1GC";
            package = pkgs.vanillaServers."vanilla-1_16_5";

            serverProperties = {
              server-port = cfg.port + 1;
              difficulty = 1;
              gamemode = 0;
              max-players = 30;
              online-mode = false;
              motd = "\\u00A7f\\u00A7lWelcome to Ismoil Chyorniy's Server\\u00A7r\\n\\u00A7lFor more, visit\:\\u00A7r \\u00A7nhttps\://niggerlicious.uz";
              enable-rcon = true;
              "rcon.port" = cfg.rcon + 1;
              "rcon.password" = "F1st1ng15300Buck";
            };

            symlinks = {
              "server-icon.png" = ./server-icon-2.png;
            };
          };
        };
      };

    networking.firewall = {
      allowedTCPPorts = [
        cfg.port
        25566
      ];
      allowedUDPPorts = [
        cfg.port
        25566
      ];
    };
  };
}
