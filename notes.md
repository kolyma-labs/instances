## Building NixOS configurations

If you're unsure whether what you're doing and want to do a quick checkup, just run this:

```shell
# replace X with the instance you want to check
nix build .#nixosConfigurations.Kolyma-X.config.system.build.toplevel
```
