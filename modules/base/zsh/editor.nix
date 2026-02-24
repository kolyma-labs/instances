{ pkgs, ... }:
let
  # Nix to Toml formatter
  formatter = pkgs.formats.toml { };

  # Actual configuration
  # https://docs.helix-editor.com/configuration.html
  settings = {
    theme = "autumn_night";
    editor = {
      line-number = "relative";

      cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };

      file-picker = {
        hidden = false;
        git-ignore = true;
        git-global = true;
      };

      lsp = {
        enable = true;
        display-messages = true;
        display-inlay-hints = true;
      };

      statusline = {
        left = [
          "mode"
          "spinner"
          "read-only-indicator"
          "file-modification-indicator"
        ];

        center = [ "file-name" ];

        right = [
          "diagnostics"
          "selections"
          "position"
          "file-encoding"
          "file-line-ending"
          "file-type"
        ];

        separator = "│";

        mode = {
          normal = "SLAVE";
          insert = "MASTER";
          select = "DUNGEON";
        };
      };
    };

    keys.normal = {
      # Easy window movement
      "C-left" = "jump_view_left";
      "C-right" = "jump_view_right";
      "C-up" = "jump_view_up";
      "C-down" = "jump_view_down";

      "C-r" = ":reload";
    };
  };
in
formatter.generate "editor.toml" settings
