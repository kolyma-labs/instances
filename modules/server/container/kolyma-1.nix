{ config
, lib
, pkgs
, outputs
, ...
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
      image = "ghcr.io/kolyma-labs/gate:3014ffb25d3e15351d5c70afe0ef2f00242cc14c294aaf0facc2741041de30fb";
      ports = [ "8440:80" ];
    };

    #    _______ __     ____
    #   / ____(_) /_   / __ \__  ______  ____  ___  _____
    #  / / __/ / __/  / /_/ / / / / __ \/ __ \/ _ \/ ___/
    # / /_/ / / /_   / _, _/ /_/ / / / / / / /  __/ /
    # \____/_/\__/  /_/ |_|\__,_/_/ /_/_/ /_/\___/_/
    runner-1 = {
      image = "gitlab/gitlab-runner:latest";
      volumes = [
        "/srv/git/runner-1:/etc/gitlab-runner"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };

    runner-2 = {
      image = "gitlab/gitlab-runner:latest";
      volumes = [
        "/srv/git/runner-2:/etc/gitlab-runner"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
  };
}
