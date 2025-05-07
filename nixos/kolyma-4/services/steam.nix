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

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    glibc
  ];

  systemd.services.cs2-server = {
    description = "CS2 Server for Floss Uzbekistan";
    documentation = ["https://floss.uz/"];

    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      User = "sakhib";
      Restart = "always";

      ExecStart = pkgs.writeShellScript "start-cs2" ''
        export LD_LIBRARY_PATH=/home/sakhib/.steam/steam/linux64:$LD_LIBRARY_PATH

        # Read GLST
        steam_token=$(cat .mirage)

        # Start the damned server
        "/home/sakhib/.steam/steam/Steamapps/common/Counter-Strike Global Offensive/game/bin/linuxsteamrt64/cs2" \
          -dedicated +ip 0.0.0.0 \
          -port 27015 \
          -usercon \
          -maxplayers 10 \
          +rcon_password something \
          +map de_mirage \
          +sv_setsteamaccount $steam_token \
          +hostname "Floss Uzbekistan"
      '';

      WorkingDirectory = "/home/sakhib/.steam/steam";
      StateDirectory = "steam-server";
      StateDirectoryMode = "0750";

      # Hardening
      ProtectSystem = "strict";
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };
}
