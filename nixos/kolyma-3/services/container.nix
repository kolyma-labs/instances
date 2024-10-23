{ outputs, ... }: {
  imports = [
    outputs.nixosModules.container
  ];

  # Enable containerization
  services.containers = {
    enable = true;

    instances = {
      # bot-xinuxmgr = {
      #   image = "ghcr.io/xinux-org/xinuxmgr@sha256:0b43cfd6f01f9cc03fcdc817975a42a8e2670c844758d50d1674de3ea10b8ae0";
      #   ports = [ "8445:8445" ];
      #   environmentFiles = [
      #     /srv/bots/xinuxmgr.env
      #   ];
      # };
    };
  };
}
