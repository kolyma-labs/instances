# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/ wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  apps = import ./apps;
  auth = import ./auth;
  base = import ./base;
  bind = import ./bind;
  container = import ./container;
  extra = import ./extra;
  gate = import ./gate;
  git = import ./git;
  mail = import ./mail;
  matrix = import ./matrix;
  runner = import ./runner;
  users = import ./users;
  vpn = import ./vpn;
  web = import ./web;
}
