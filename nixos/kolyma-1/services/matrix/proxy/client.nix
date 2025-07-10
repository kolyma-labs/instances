{domains}: {
  show_labs_settings = true;
  default_theme = "dark";
  brand = "Efael's Network";

  disable_custom_urls = true;
  disable_guests = true;

  branding = {
    welcome_background_url = "https://cdn1.kolyma.uz/element/bg-efael.png";
    auth_header_logo_url = "https://cdn1.kolyma.uz/element/efael.svg";
  };

  permalink_prefix = "https://matrix.to";
  enable_presence_by_hs_url = "\n";

  integrations_ui_url = "";
  integrations_rest_url = "";
  integrations_widgets_urls = "";
  integrations_jitsi_widget_url = "";

  room_directory = {
    servers = ["matrix.org"];
  };

  embedded_pages = {
    homeUrl = "";
  };

  default_server_config = {
    "m.homeserver" = {
      base_url = "https://${domains.server}";
      server_name = "${domains.main}";
    };
    "m.identity_server" = {
      base_url = "";
    };
  };

  # Enable Element Call Beta
  features = {
    feature_video_rooms = true;
    feature_group_calls = true;
    feature_element_call_video_rooms = true;
  };

  element_call = {
    url = "https://call.efael.net";
    participant_limit = 50;
    brand = "Efael Call";
  };
}
