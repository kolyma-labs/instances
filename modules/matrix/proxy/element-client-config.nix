{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.kolyma.matrix;
in
{
  default_server_config = {
    "m.homeserver" = {
      base_url = "https://matrix.${config.kolyma.matrix.domain}";
      server_name = "${config.kolyma.matrix.domain}";
    };
    "m.identity_server" = {
      base_url = "";
    };
  };
  default_theme = "dark";
  default_country_code = "UZ";
  permalink_prefix = "https://matrix.to";
  disable_custom_urls = true;
  disable_guests = true;
  brand = "Element Floss";

  # TODO: Configure these
  integrations_ui_url = "";
  integrations_rest_url = "";
  integrations_widgets_urls = "";
  integrations_jitsi_widget_url = "";

  bug_report_endpoint_url = "https://element.io/bugreports/submit";
  show_labs_settings = true;
  room_directory = {
    servers = [ "matrix.org" ];
  };
  # TODO: This looks wrong
  enable_presence_by_hs_url = "\n";
  embedded_pages = {
    homeUrl = "";
  };
  branding = {
    auth_footer_links = [
      {
        text = "Privacy";
        url = "https://floss.uz/privacy";
      }
    ];
    # FUTUREWORK: Replace with floss.uz logo
    auth_header_logo_url = "themes/element/img/logos/element-logo.svg";
  };
  # Enable Element Call Beta
  features = {
    feature_video_rooms = true;
    feature_group_calls = true;
    feature_element_call_video_rooms = true;
  };
  element_call = {
    url = "https://call.element.io";
    participant_limit = 50;
    brand = "Element Call";
  };
}
