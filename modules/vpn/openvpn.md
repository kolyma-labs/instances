# OpenVPN Configurations {#kolyma-openvpn}

_Wiki:_ [nixos.wiki](https://nixos.wiki/wiki/OpenVPN)
_Options:_ [search.nixos.org](https://search.nixos.org/options?channel=25.05&query=openvpn)
_Manual:_ N/A

# About

This module configures openvpn instance in a server with secrets passed to the interfaces. Refer to [openvpn secrets generation] for more information on how to generate secrets for deployment. The keys for Kolyma instances are kept at [Orzklv](https://github.com/orzklv)'s machine and he is the only one to maintain deployments.

Upon deployment, module generate `/etc/openvpn/output.ovpn` file which will contain connection settings for OpenVPN clients. However, those configurations are only for one instances and new keys shall be replaced with ones in the configuration to avoid connection conflicts.

# Notes

_By Orzklv | 28th Sep 2025_
OpenVPN is very slow as fuck with only 3 mbps rate of speed which is not quite enough to even watch something in the Internet. Therefore, it was decided to switch to wireguard which seems very optimized and fast enough to satisfy my requirements.

[openvpn secrets generation]: https://forums.opto22.com/t/recommended-openvpn-server-setup-tutorial/5383/4.
[Orzklv]: https://github.com/orzklv
