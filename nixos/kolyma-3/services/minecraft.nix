{ pkgs, ... }: {
  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    openFirewall = true;
    package = pkgs.unstable.minecraft-server;
    jvmOpts = "-Xms12288M -Xmx12288M -XX:+UseG1GC -XX:ParallelGCThreads=4 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";

    whitelist = {
      ORZKLV = "3e220001-9544-48bb-8fd0-ca7139727207";
      Overlord77 = "32274912-6f48-4e6d-9819-1bde2ead4d27";
    };

    serverProperties = {
      server-port = 25565;
      difficulty = 3;
      gamemode = 1;
      max-players = 20;
      motd = "\\u00A74WELCOME TO CXSMXS SERVER!\\u00A7r\\n\\u00A7c\\u00A7k!!!\\u00A7r \\u00A7bHAVE A NICE TRIP! \\u00A7r\\u00A7c\\u00A7k!!!";
      white-list = true;
      enable-rcon = true;
      "rcon.password" = "Fuck1ngSlav3s!!!";
    };
  };
}
