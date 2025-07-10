{
  config,
  domains,
}: let
  sopsFile = ../../../../secrets/efael.yaml;
  owner = config.systemd.services.matrix-authentication-service.serviceConfig.User;
in {
  sops.secrets = {
    "matrix/mas/mail" = {
      inherit owner sopsFile;
      key = "mail/support/raw";
    };
    "matrix/mas/client/id" = {
      inherit owner sopsFile;
      key = "matrix/id";
    };
    "matrix/mas/client/secret" = {
      inherit owner sopsFile;
      key = "matrix/secret";
    };
  };

  sops.templates."extra-mas-conf.yaml" = {
    inherit owner;
    content = ''
      email:
        from: '"Efael" <noreply@${domains.main}>'
        reply_to: '"No reply" <noreply@${domains.main}>'
        transport: smtp
        mode: starttls  # plain | tls | starttls
        hostname: mail.oss.uzinfocom.uz
        port: 587
        username: noreply@${domains.main}
        password: "${config.sops.placeholder."matrix/mas/mail"}"
      clients:
        - client_id: ${config.sops.placeholder."matrix/mas/client/id"}
          client_auth_method: client_secret_basic
          client_secret: "${config.sops.placeholder."matrix/mas/client/secret"}"
      matrix:
        kind: synapse
        homeserver: ${domains.main}
        secret: "${config.sops.placeholder."matrix/mas/client/secret"}"
        endpoint: "https://${domains.server}"
      secrets:
        encryption: "7fde896f8e24ad148226289ee98d38654f5ed7a7f90df08073c075765de6cf11"
        keys:
          - kid: eEpX9YcLZY
            key: |
              -----BEGIN RSA PRIVATE KEY-----
              MIIEpAIBAAKCAQEAnR+ooJrpaeQde40KQRF+NkBOME4X1MoQuC8Sxofg7RcSIzIz
              fUC45y9tuWI6Hx0C83wQyQ0XMkBlDzrAGBgcNdumwP7nN0BO0r+C9jbk6j1di8KQ
              pthT47/EsQxQ48ZP0g8oIjV+JV9ItQbqoi/iGr21GRoN3Ak9eY48ZG9TR+aS3K6h
              hI9ZzfX/G3lIC6dyuEmrWOapdCkhnVgDwoTyWXRN0RbfB6v7QlyFvRQIxR6DivbU
              /yHoMSkWiTfBD9JYETvjY+3cjjO15lm3hQkJYRGZK7ptt75QfWzO8ARc56DmgaKZ
              KMxRC3n4ZH3+UDkPG82rNTTNUQCIpSwa21HPXwIDAQABAoIBACFs+Lyh+AH062i7
              SnEpPYZhC8Eu+9bi3cexC/d8NJd7jvo51cZRnIRiDJ+hi+fOjjAqNo/u3v5rwJQK
              1Y7KokW64rCwCZQxdBNVdpDWgMBsKZhv3cIAx2fuBfP8QMEUESsI2mrcomdk69zH
              CedS9HDn5rzeVBB5TsCrR6G+JSNoTn3egMdIvch3YHzgMY6qj4IzirKBqGPrQQVa
              TT+IaqR6IjhuQQN6GgexVPXR1TxfJyADhlYjSgST1mocuhYOFk0lBsvSNGOSVk+B
              9g226qQBDZH8ZvE/3bY2MBnD3MspFxw1isOwoImFUGfR2CBdF4eaUVWv3TTA7Eky
              kvdd90ECgYEAw5beT07TGq1T+qUvvKieO8xl82GlEvuXdMD7pjv6D0AcfOHKjf6X
              hJwbcBSqOI6w8C8GvEDPNdDF/i1k6Q/raVb4t9d3ZHRAxKn1MutDp5LZeXv2GOEM
              ODDno+1Jp+mM/ejMjwJwrRfyF0onkGvtgKbbPW8TqKn6XAd+kQ7eRxECgYEAzadV
              Um8kodF45/8kvVCsCytwURDFxrJg45q/i27cqtJzyWVkdEIgvPqVUQTLlryJDdj4
              PivEIg4qaZeWr9itmboEhVJ+njAUeR2vzzEzgm+WlakMCRWWm6heIAf7QbwypCg6
              yo8IBEZFjtI+oiVGA181nZ/qOZw5mtudYHxXD28CgYEAmpn3caLx9SVKu1W1DSAP
              q17eu2nUjNO4HT6p6/V+rG1V11S2wlSaueSXP5nmDzyjGcdiQI3N/FDhIBALsrm1
              sBdiFBdJtWq7A3kAa1ZRrPTD2GYm2fWRrhziDM50qThQDSfmAajBHeFOqCAic+ML
              4eSCaeYSGQD696Go5spk4rECgYEAjahg3kqOqiRXKz8VuI4UJBGE6WIrSaXflYgn
              vszblZMnjKeZ3Xcbg/D733X1Ity1b2NwA6s0C91EG73+Xxxa4FRA/vEHJMGrqI3p
              Z0fV2lgxGt/52VwUhR4hz+CPkwUmwOqxLIv/kqoxCaMK37fbFUGE9hGMTqitCV2T
              dz3O3mMCgYBFjxSzgUTHfJADscuYATu8ivne8fd6p3q2PXa4STbsQEtY1/bPcS8W
              oS/lKoScA8xPKsG2UNVD5phz5ZlR3XMtJO7IbJNaF0ewJ6sCNHTYvLweDb7MJkZY
              qv8dF2yrwzltmCu6FEdS83DJgIjDdj9LsKbTLXpZSabpPODgtiOAug==
              -----END RSA PRIVATE KEY-----
          - kid: Q6ZMd9vj85
            key: |
              -----BEGIN EC PRIVATE KEY-----
              MHcCAQEEIFoxl6YvEvgQlQewSzPMOPs5uD9hATJ5DneUpUfP5ooXoAoGCCqGSM49
              AwEHoUQDQgAEj1YiDrq7mWqS28MBXSu7S4qvGUJpM2lqAqreBsnHZljI+MR+RctM
              AZK9kA3miy162MRWVG1ltDXbjSUk813UUA==
              -----END EC PRIVATE KEY-----
          - kid: qtFJhS7Czf
            key: |
              -----BEGIN EC PRIVATE KEY-----
              MIGkAgEBBDAFnv/4eJGUfGIo4S8g7MBUL3oIlSvSKIxCZTYe46aB33fz6cM/zo3G
              RhlHWBt2/cSgBwYFK4EEACKhZANiAAQeplHv+UNiiPgGrdFr6o9Z95/lqzroNlOE
              Wb4Yd3MQVyotLXS1OZJTwVQNwQxasTvrnEkRISNluYzFDi563XJrLyOIigx9nbzg
              cEcjj33uBEuIGLOF7o8t7FhZOxT/+zQ=
              -----END EC PRIVATE KEY-----
          - kid: BxkE8ju98o
            key: |
              -----BEGIN EC PRIVATE KEY-----
              MHQCAQEEIN5Whbwh32Z83r99gme1S/NVc8LtEtzoTv8cUhnVAi/HoAcGBSuBBAAK
              oUQDQgAEapEEm611BWngQBFa68+EDIa1UXqYTWVvqHGTvaKfHIROWrhoVejlTYAk
              PvEW3Xx2WGNvxuFNoGnsUrVgESpmgg==
              -----END EC PRIVATE KEY-----
    '';
  };

  services.matrix-authentication-service = {
    enable = true;
    createDatabase = true;
    extraConfigFiles = [
      config.sops.templates."extra-mas-conf.yaml".path
    ];

    settings = {
      http = {
        public_base = "https://${domains.auth}";
        issuer = "https://${domains.auth}";
        listener = [
          {
            name = "web";
            resources = [
              {name = "discovery";}
              {name = "human";}
              {name = "oauth";}
              {name = "compat";}
              {name = "graphql";}
              {
                name = "assets";
                path = "${config.services.matrix-authentication-service.package}/share/matrix-authentication-service/assets";
              }
            ];
            binds = [
              {
                host = "0.0.0.0";
                port = 8080;
              }
            ];
            proxy_protocol = false;
          }
          {
            name = "internal";
            resources = [
              {name = "health";}
            ];
            binds = [
              {
                host = "0.0.0.0";
                port = 8081;
              }
            ];
            proxy_protocol = false;
          }
        ];
      };

      account = {
        email_change_allowed = true;
        displayname_change_allowed = true;
        password_registration_enabled = true;
        password_change_allowed = true;
        password_recovery_enabled = true;
      };

      passwords = {
        enabled = true;
        minimum_complexity = 3;
        schemes = [
          {
            version = 1;
            algorithm = "argon2id";
          }
          {
            version = 2;
            algorithm = "bcrypt";
          }
        ];
      };
    };
  };
}
