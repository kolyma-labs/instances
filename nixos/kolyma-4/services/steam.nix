{
  lib,
  pkgs,
  ...
}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  systemd.services.cs2-server = {
    description = "CS2 Server for Floss Uzbekistan";
    documentation = ["https://floss.uz/"];

    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      User = "sakhib";
      Group = "sakhib";
      Restart = "always";

      ExecStart = pkgs.writeShellScript "start-cs2" ''
        # Read GLST
        steam_token=$(cat .token)

        # Start the damned server
        "/home/sakhib/.steam/steam/Steamapps/common/Counter-Strike Global Offensive/game/bin/linuxsteamrt64/cs2" \
          -dedicated +ip 0.0.0.0 \
          -port 27015 \
          +map de_mirage \
          -maxplayers 10 \
          +sv_setsteamaccount $steam_token \
          +hostname "Floss Uzbekistan"
      '';

      WorkingDirectory = "/home/sakhib/.steam/steam";
      StateDirectory = "steam-server";
      StateDirectoryMode = "0750";

      # Hardening
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };
}
