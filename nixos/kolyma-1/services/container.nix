{ outputs, ... }: {
  imports = [
    outputs.nixosModules.container
  ];

  # Enable containerization
  services.containers = {
    enable = true;

    instances = {
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
  };
}
