{ outputs, ... }: {
  imports = [
    outputs.serverModules.container
  ];

  # Enable Nameserver hosting
  services.containers = {
    enable = true;

    instances = {
      #    _______ __  __          __
      #   / ____(_) /_/ /   ____ _/ /_
      #  / / __/ / __/ /   / __ `/ __ \
      # / /_/ / / /_/ /___/ /_/ / /_/ /
      # \____/_/\__/_____/\__,_/_.___/
      git = {
        image = "gitlab/gitlab-ee:latest";
        hostname = "git.kolyma.uz";
        volumes = [
          "/srv/git/config:/etc/gitlab"
          "/srv/git/logs:/var/log/gitlab"
          "/srv/git/data:/var/opt/gitlab"
        ];
        ports = [
          "8450:80"
          "22:22"
        ];
        extraOptions = [
          "--shm-size=268435456"
        ];
      };

      #    _____ __        __                    __
      #   / ___// /_____ _/ /      ______ ______/ /_
      #   \__ \/ __/ __ `/ / | /| / / __ `/ ___/ __/
      #  ___/ / /_/ /_/ / /| |/ |/ / /_/ / /  / /_
      # /____/\__/\__,_/_/ |__/|__/\__,_/_/   \__/
      mail = {
        image = "stalwartlabs/mail-server:latest";
        volumes = [
          "/srv/mail:/opt/stalwart-mail"
        ];
        ports = [
          "25:25"
          "110:110"
          "143:143"
          "465:465"
          "587:587"
          "993:993"
          "995:995"
          "4190:4190"
          "8460:8080"
        ];
      };
    };

    ports = [
      22 # Git SSH
      25 # Mail SMTP
      110 # Mail POP3
      143 # Mail IMAP
      465 # Mail SMTPS
      587 # Mail Submission
      993 # Mail IMAPS
      995 # Mail POP3S
      4190 # Mail Sieve
    ];
  };
}
