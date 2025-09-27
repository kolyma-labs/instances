<p align="center">
    <img src=".github/assets/header.png" alt="Kolyma's {Instances}">
</p>

<p align="center">
    <h3 align="center">Kolyma's Nix configurations for all server instances.</h3>
</p>

<p align="center">
    <img align="center" src="https://img.shields.io/github/languages/top/kolyma-labs/instances?style=flat&logo=nixos&logoColor=ffffff&labelColor=242424&color=242424" alt="Top Used Language">
    <a href="https://github.com/kolyma-labs/instances/actions/workflows/test.yml"><img align="center" src="https://img.shields.io/github/actions/workflow/status/kolyma-labs/instances/test.yml?style=flat&logo=github&logoColor=ffffff&labelColor=242424&color=242424" alt="Test CI"></a>
</p>

## About

This repository is intended to keep all configurations of global servers ran by Kolyma's Laboratory. Configurations contain both service and
environmental implications.

> Maybe it's time to start embracing declarative & reproducible server configs?!

## Features

- Services & Containers
- Rust made replacements
- Key configurations
- Software configurations
- Selfmade scripts

## Get NixOS Ready on your server

This is actually quite hard task as it requires a few prequisites to be prepared beforehand. You may refer to [bootstrap](https://github.com/kolyma-labs/bootstrap) and [installer](https://github.com/kolyma-labs/instances) for further instructions.

## Installing configurations

After you get NixOS running on your machine, the next step is to apply declarative configurations onto your machines:

```shell
# Kolyma Station {1,2,3}
sudo nixos-rebuild switch --flake github:kolyma-labs/instances#Kolyma-X --upgrade
```

## Thanks

- [Template](https://github.com/Misterio77/nix-starter-configs) - Started with this template
- [Example](https://github.com/Misterio77/nix-config) - Learned from his configurations
- [Nix](https://nixos.org/) - Masterpiece of package management

## License

This project is licensed under the MIT License - see the [LICENSE](license) file for details.

<p align="center">
    <img src=".github/assets/footer.png" alt="Kolyma's {Instances}">
</p>
