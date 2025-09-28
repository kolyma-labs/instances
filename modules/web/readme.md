# Web Server / Proxy {#kolyma-www}

_Wiki:_ [nixos.wiki](https://nixos.wiki/wiki/Nginx)
_Manual:_ [manual](https://nixos.org/manual/nixos/stable/#module-services-strfry-reverse-proxy)
_Options:_ [search.nixos.org](https://search.nixos.org/options?channel=25.05&query=services.nginx.)

## About

Whatever to be exposed via HTTP/HTTPS protocol must be done via web module which this abstraction actually does. Some part of module is actually binding to `services.nginx.<you name it>` and directly plugs some of configurations to nginx whereas some of it configuring very essential basic configs. By default, service serves [dancing miku] for unknown or unresolved requests, if appointed, it will redirect to corresponding internal services.

### Anubis

Also, upon enabling anubis, it will just add nginx user to anubis group, so nginx can access unix sockets exposed for nginx. Further anubis related configurations must be done from developers' side.

## Notes

_By Orzklv | 28th Sep 2025_
This note was supposed to be written long time ago, but those times this kind of docs were absent. Actually web module used to be 2 components containing both nginx and caddy at the same time. However, caddy had lots of, lots of issues with other services like mail server (postfix) or mastodon which couldn't utilize caddy properly and led to proxy failures. To resolve this issue, it was decided to ditch caddy support and maintain only nginx.

[dancing miku]: https://github.com/kolyma-labs/gate
