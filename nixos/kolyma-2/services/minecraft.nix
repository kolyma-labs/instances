{
  config,
  lib,
  ...
}: let
in {
  virtualisation.oci-containers.containers = {
    minecraft = {
      image = "itzg/minecraft-server:latest";
      ports = [
        "127.0.0.1:25565:25565"
      ];

      volumes = [
        "/srv/minecraft:/data"
      ];

      environment = {
        EULA = "TRUE";
        TYPE = "CUSTOM";
        MEMORY = "24G";
        EXTRA_ARGS = "--log-strip-color";
        CUSTOM_SERVER = "https://github.com/CyberdyneCC/Thermos/releases/download/58/Thermos-1.7.10-1614-server.jar";
        JVM_OPTS = lib.strings.concatStringsSep " " [
          "-XX:+UseG1GC"
          "-XX:+UseFastAccessorMethods"
          "-XX:+OptimizeStringConcat"
          "-XX:MetaspaceSize=2048m"
          "-XX:MaxMetaspaceSize=4096m"
          "-XX:+AggressiveOpts"
          "-XX:ParallelGCThreads=15"
          "-XX:MaxGCPauseMillis=10"
          "-XX:+UseStringDeduplication"
          "-XX:hashCode=5"
          "-Dfile.encoding=UTF-8"
        ];
      };
    };
  };

  networking = {
    firewall = {
      allowedUDPPorts = [25565];
      allowedTCPPorts = [25565];
    };
  };
}
