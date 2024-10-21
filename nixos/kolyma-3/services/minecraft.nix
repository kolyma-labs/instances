{ ... }: {
  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    openFirewall = true;

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
      motd = "§f§lWelcome to Orzklv's CXSMXS§r\n§lMore at\:§r §nhttps\://cxsmxs.space";
      white-list = true;
      enable-rcon = true;
      "rcon.password" = "Fuck1ngSlav3s!!!";
    };
  };
}
