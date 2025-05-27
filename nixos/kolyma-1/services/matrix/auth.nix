{
  config,
  domains,
}: let
in {
  sops.secrets = {
    "matrix/mail" = {
      owner = config.systemd.services.matrix-synapse.serviceConfig.User;
      key = "mail/floss/support/raw";
    };
    "matrix/mas/auth/id" = {
      owner = config.systemd.services.matrix-synapse.serviceConfig.User;
      key = "matrix/auth/id";
    };
    "matrix/mas/auth/secret" = {
      owner = config.systemd.services.matrix-synapse.serviceConfig.User;
      key = "matrix/auth/secret";
    };
  };

  sops.templates."extra-mas-conf.yaml" = {
    owner = config.systemd.services.matrix-authentication-service.serviceConfig.User;
    content = ''
      email:
        from: '"Efael" <noreply@floss.uz>'
        reply_to: '"No reply" <noreply@floss.uz>'
        transport: smtp
        mode: tls # plain | tls | starttls
        hostname: mail.floss.uz
        port: 587
        username: noreply@floss.uz
        password: "${config.sops.placeholder."matrix/mail"}"
      clients:
        - client_id: 0000000000000000000SYNAPSE
          client_auth_method: client_secret_basic
          client_secret: "samething"
      matrix:
        kind: synapse
        homeserver: ${domains.main}
        secret: "samething"
        endpoint: "http://localhost:8008"
      secrets:
        encryption: e724403e1380d06bfcec459d0fbd6469cd5c202dcb4b13f1756edf927990d07c
        keys:
        - kid: DQhwdhHMxc
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            MIIEpAIBAAKCAQEAtKFyOEbfIgVITbZTkhkWXsauO0fbxPVh4szHNHAJcmzu/r2a
            nL7A2DURpErWgPML7Zr6tKUxJFRlb9eZJuU69yWYVlH1kWu7ymdhE5u7Sd+3hocB
            HfuZfVMxsZgMDLGTwx505Jr1/bVwoUfx5lS/LuNsVDO3Wd1yc9Ly02WGY8g2qBTs
            4fcahsSECyMYOg/teYAguyi8nFqYl0DlzW3RyuP+lOMglb8O6SFlo5MeamjPnHCt
            T5iQF90gn+irQTLBoGJmyFVXUZi30C11ZCSODrPiq9+8nuT5aliPRDQzSrTGrT4Z
            pr+MzEGWrjrAj7NeQiXNeOCF4ISOpWYY5IWbrQIDAQABAoIBAQCbOiLuOfmHQwLf
            xdALvYN770HLr/UtTbLRNSn75kw4CWVZhZdZHJSdOP3wMmAkcLnPd1/73fpdPint
            81mqE1SZD7XaeJSQZAT969mBAFPzKE6PTXWoTo+ZI+WQuRmhzvkstP+/dWvwm/wu
            naVES5AAu3Bc7BSlJak14BLNmHHlTLfKe2qp5KsrRnrN/uEl7sSRLNoDWN8bACzh
            HZY2pTMdEfhYlf1zIh/rXFICYv/zQLBernw9l1LPjJo4I7XoQqshFXkJNljxdMNt
            nYP6KNGseEvXeuBXH6Pv60wzCYPQyAMn4vzhD8Qlhjr4d4Dpab4d8in7UJtQMHbW
            IjWYdoABAoGBAM7JsI7m1O/1h/6ooHs6nfDS0VNDHtESrUWXs1cxYhh1ASezwsrp
            iHVkCu7UbmKceFMop3jgN0DeJ5/FKwL+3dbno0U76soAAxueDd797ahRfd84MG5A
            qLMk1YFxz69aM9HLmCw89bvit0zmZlXixbfmHkUW2f7dR1BOT5Kn8YDJAoGBAN+e
            KMezyoHEgGuxFZlW78HjQhji3KwsvB/wFlLhmAsSFMdEjVNN0LHlGtb14mVNpUUJ
            dsFTXSmFflTn11bACcYyDY7KdJQenO7y2KvRpa4UJcHs9p20WDlmmzeTKqqCxvmb
            8o9uYqpFIR9QU91vWkUpMRjCDNMU7mAOPzLFGvnFAoGBAJePmAqFARkHGq/5o/Xt
            1okF20ptbY7LY5gYQefsV/uY9knFJUZXuB5iPukhZe58xGwe5fBgVd8DdINTndzK
            NIooqLA75DA9pgl95KjF8IRnhhwvML/+QCddHeeMJS5erJBd6qCx5WHaH4MLc4IL
            feL1lMYKo6h7QqOHYicZVJaRAoGAd1nwBB6m8DoUHOaIU65+CysjpSq4g0DhK961
            24jC4O3Gn1CsaZD32WshtyfHrTATDNTvSGIZMEcq1WBko82dqeYfLF5MeJ4aPsLo
            +FPOLSpduLKkMioGiKSGJdRrilSApMsiXIGbMavx8Mer6106ff1tUfyIYcUjMauI
            +a0QJ80CgYAD0EtY23Zvl71sF7oy2DzCT7xyLm7aHtEXBQTFz9Mz4FQFI3GNXYj8
            RFfKiu7DOJHKhXvr0akIBenquuN2BE0oDpvwf7s5OchGIYTMZKIyRCLDiiUyR37k
            rMNZbArXsj22BueFWYrm8JkKP7auVHNJKazthFrv53KPesawes9VYw==
            -----END RSA PRIVATE KEY-----
        - kid: fK7g4m3Ozg
          key: |
            -----BEGIN EC PRIVATE KEY-----
            MHcCAQEEIAkGSEhYIHsXJrzfm5f5kujfqYWiVc1vdduOmlh5URI9oAoGCCqGSM49
            AwEHoUQDQgAEGsj6JBqiYxP9wMx8fGvKqQWT+aT1td5egbl1SezIfg1dxZEgYUVH
            6yjXaQN0cQ9s509YkMZEstdXgFWutMzw3Q==
            -----END EC PRIVATE KEY-----
        - kid: cePSmzchGk
          key: |
            -----BEGIN EC PRIVATE KEY-----
            MIGkAgEBBDAiTVReSaBjuWWFo3NwLwPp1oc6S38dL151fZDcvktJNpEJPWbhvtEW
            tFpX4k8KdaagBwYFK4EEACKhZANiAAQQOTVsSQgQYavRrSGIOkGYSxIJH3I3vQTp
            IHvlzwyWyRj2+x39vuCvCvypIOJHKmeVI29iiIwnSqA4+qndn2NNd2Y5zNi3CFOW
            fcznXiXkzR4SRP6fhdKmndYhQPLaW5U=
            -----END EC PRIVATE KEY-----
        - kid: SxnO3hEMCg
          key: |
            -----BEGIN EC PRIVATE KEY-----
            MHQCAQEEIDLndBZGc5beWiVVeDClnWIS8PG1bkkBWpqmN8OaRFRFoAcGBSuBBAAK
            oUQDQgAECcZeokwZgclVvUUz8gSkMOIUwWnN2y9WkynOYWSMH4wjl4j2SSLshksP
            PjB1Ne1+ICWa7dia0dDG8OhdCX9UQA==
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
                port = 8090;
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
