{ pkgs, ... }: {
  home.packages = with pkgs; [ winbox ];

  programs = {
    ghostty = {
      enable = true;
      settings = {
        command = "${pkgs.bashInteractive}/bin/bash -l -c nu";
        window-inherit-working-directory = true;
        window-decoration = "auto";
        macos-titlebar-style = "hidden";
        focus-follows-mouse = true;
        shell-integration-features = "sudo,ssh-env,ssh-terminfo";

        macos-option-as-alt = true;
        macos-non-native-fullscreen = true;
        window-save-state = "never";
        keybind = [ "global:cmd+grave_accent=toggle_quick_terminal" ];

        copy-on-select = "clipboard";
        confirm-close-surface = false;
        scrollback-limit = 314572800; # 300 MiB

        background-opacity = 0.95;
        background-blur-radius = 20;
        window-padding-x = 6;
        window-padding-y = 6;
        window-padding-balance = true;
        unfocused-split-opacity = 0.85;
        font-thicken = true;
      };
    };
    sioyek = {
      enable = true;
      config = {
        case_sensitive_search = "0";
        default_dark_mode = "1";
        dark_mode_background_color = "0.0 0.0 0.0";
        font_size = "20";
        prerender_next_page_presentation = "1";
        should_launch_new_window = "1";
        super_fast_search = "1";
      };
    };
  };

  stylix.targets.ghostty.enable = true;
}
