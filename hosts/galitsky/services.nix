{ outputs, ... }:
{
  imports = [
    # Top level abstractions
    outputs.nixosModules.minecraft

    # Per app preconfigured abstractions
    # outputs.nixosModules.apps.example
  ];

  # Kolyma services
  kolyma = {
    # mc://niggerlicious.uz
    minecraft.enable = true;
  };
}
