{
  config,
  lib,
  ...
}: let
in {
  virtualisation.oci-containers.containers = {
    minecraft = {
      image = "itzg/minecraft-server:java8";
      ports = [
        "127.0.0.1:25565:25565"
      ];

      volumes = [
        "/srv/minecraft:/data"
      ];

      environment = {
        EULA = "TRUE";
        TYPE = "CRUCIBLE"; # CUSTOM
        MEMORY = "24G";

        VERSION = "1.7.10";
        CRUCIBLE_RELEASE = "latest";
        # EXTRA_ARGS = "--log-strip-color";
        # CUSTOM_SERVER = "https://github.com/CyberdyneCC/Thermos/releases/download/58/Thermos-1.7.10-1614-server.jar";
        # JVM_OPTS = lib.strings.concatStringsSep " " [
        #   "-XX:+UseG1GC"
        #   "-XX:+OptimizeStringConcat"
        #   "-XX:MetaspaceSize=2048m"
        #   "-XX:MaxMetaspaceSize=4096m"
        #   "-XX:ParallelGCThreads=15"
        #   "-XX:MaxGCPauseMillis=10"
        #   "-XX:+UseStringDeduplication"
        #   "-XX:+UnlockExperimentalVMOptions"
        #   "-XX:hashCode=5"
        #   "-Dfile.encoding=UTF-8"
        # ];
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
