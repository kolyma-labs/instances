{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  config = {
    users.motd = ''
          __ __      __                         ________ __
         / //_/___  / /_  ______ ___  ____ _   / ____/ //_/
        / ,< / __ \/ / / / / __ `__ \/ __ `/  / / __/ ,<
       / /| / /_/ / / /_/ / / / / / / /_/ /  / /_/ / /| |
      /_/ |_\____/_/\__, /_/ /_/ /_/\__,_/   \____/_/ |_|
                   /____/

      Welcome to Kolyma's Global Server Infrastructure!

      All Kolyma servers are managed via NixOS'es declarative configuration system.
      Any global changes has to be applied to the public configuration repository at:
      https://github.com/kolyma-labs/instances

      # Server Instances & Applications
      Any server instances and applications must be hosted at /srv path. Each app
      should have its own directory with short and clear name. For example:
      /srv/kolyma-website, /srv/kolyma-telegram-bot

      # Docker
      Only docker compose (not docker run) services can be hosted imperatively, feel
      free to to use globally available docker compose for this purposes.
    '';
  };
}
