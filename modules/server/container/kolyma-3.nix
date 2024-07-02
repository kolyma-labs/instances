{
  config,
  lib,
  pkgs,
  outputs,
  ...
}: {
  imports = [
    outputs.nixosModules.docker
  ];

  virtualisation.oci-containers.containers = {
    #  _       __     __         _ __
    # | |     / /__  / /_  _____(_) /____
    # | | /| / / _ \/ __ \/ ___/ / __/ _ \
    # | |/ |/ /  __/ /_/ (__  ) / /_/  __/
    # |__/|__/\___/_.___/____/_/\__/\___/
    website = {
      image = "ghcr.io/kolyma-labs/gate@sha256:2a1cfdfe8e78aa4173c260f5f1a40640785e182ca4aebfe09dc7b0544c4c24fd";
      ports = ["8440:80"];
    };

    khakimovs = {
      image = "ghcr.io/khakimovs/website@sha256:87827e103623f301dff0b55dfea34ee9a841c5a5718a065b777a1e2d730db494";
      ports = ["8441:3000"];
    };

    bot-xinuxmgr = {
      image = "ghcr.io/xinux-org/xinuxmgr@sha256:0b43cfd6f01f9cc03fcdc817975a42a8e2670c844758d50d1674de3ea10b8ae0";
      ports = ["8445:8445"];
      environmentFiles = [
        /srv/bots/xinuxmgr.env
      ];
    };

    #     __  ___                                  ______
    #    /  |/  /___  __  ______  ______________ _/ __/ /_
    #   / /|_/ / __ \/ / / / __ \/ ___/ ___/ __ `/ /_/ __/
    #  / /  / / /_/ / /_/ / / / / /__/ /  / /_/ / __/ /_
    # /_/  /_/\____/\__, /_/ /_/\___/_/   \__,_/_/  \__/
    #              /____/
    # minecraft = {
    #   image = "itzg/minecraft-server:latest";
    #   volumes = [
    #     "/srv/minecraft:/data"
    #   ];
    #   ports = [
    #     "25565:25565"
    #     "25656:25656"
    #   ];
    #   environment = {
    #     TYPE = "PAPER";
    #     EULA = "TRUE";
    #     MEMORY = "12G";
    #   };
    # };

    #    _______ __     ____
    #   / ____(_) /_   / __ \__  ______  ____  ___  _____
    #  / / __/ / __/  / /_/ / / / / __ \/ __ \/ _ \/ ___/
    # / /_/ / / /_   / _, _/ /_/ / / / / / / /  __/ /
    # \____/_/\__/  /_/ |_|\__,_/_/ /_/_/ /_/\___/_/
    #   runner-1 = {
    #     image = "gitlab/gitlab-runner:latest";
    #     volumes = [
    #       "/srv/git/runner-1:/etc/gitlab-runner"
    #       "/var/run/docker.sock:/var/run/docker.sock"
    #     ];
    #   };

    #   runner-2 = {
    #     image = "gitlab/gitlab-runner:latest";
    #     volumes = [
    #       "/srv/git/runner-2:/etc/gitlab-runner"
    #       "/var/run/docker.sock:/var/run/docker.sock"
    #     ];
    #   };
    # };
  };

  # Necessary firewall rules for docker containers
  networking.firewall.allowedUDPPorts = [
    # 25565 # Minecraft
  ];
  networking.firewall.allowedTCPPorts = [
    # 25565 # Minecraft
  ];
}
