{
  outputs,
  pkgs,
  ...
}: let
  haskell-restart = pkgs.writeShellScript "haskell-restart.sh" ''
    cd /srv/haskell
    rm -rf ./data/rabbitmq/.erlang.cookie
    docker compose restart
  '';
in {
  imports = [outputs.nixosModules.container];

  # Enable containerization
  services.containers = {
    enable = true;
    ports = [];

    instances = {};
  };

  systemd.services = {
    "haskell-restart" = {
      wantedBy = ["multi-user.target"];
      after = ["docker.service"];
      path = [pkgs.bash];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${haskell-restart}";
        ExecReload = "${haskell-restart}";
        RemainAfterExit = "yes";
      };
    };
  };
}
