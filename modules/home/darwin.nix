{ pkgs, user, config, ... }:
{
  imports = [
    ./shared.nix
    ./gui.nix
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/secrets.yaml;
    secrets = {
      "ssh/id_github_felixmaximilian" = {
        path = "${config.home.homeDirectory}/.ssh/id_github_felixmaximilian";
        mode = "0600";
      };
      "ssh/private-mac-git-key" = {
        path = "${config.home.homeDirectory}/.ssh/private-mac-git-key";
        mode = "0600";
      };
      "ssh/yaak_gpu_cluster" = {
        path = "${config.home.homeDirectory}/.ssh/yaak_gpu_cluster";
        mode = "0600";
      };
    };
  };

  home = {
    username = user;
    homeDirectory = "/Users/${user}";
    packages = with pkgs; [
      whatsapp-for-mac
      google-chrome
      chatgpt
      bitwarden-desktop
      slack
      discord
      meetingbar
      obsidian
      vscode
      zoom-us
      # telegram-desktop
      # rerun
    ];
  };

  home.file = {
    ".ssh/id_github_felixmaximilian.pub".source = ../../secrets/public_keys/id_github_felixmaximilian.pub;
    ".ssh/private-mac-git-key.pub".source = ../../secrets/public_keys/private-mac-git-key.pub;
    ".ssh/yaak_gpu_cluster.pub".source = ../../secrets/public_keys/yaak_gpu_cluster.pub;
  };

  programs = {
    ssh = {
      enable = true;
      matchBlocks = {
        "*github.com" = {
          identityFile = "~/.ssh/id_github_felixmaximilian";
          extraOptions.AddKeysToAgent = "yes";
        };
        "luna" = {
          hostname = "192.168.178.81";
          user = "max";
          identityFile = "~/.ssh/id_github_felixmaximilian";
          identitiesOnly = true;
        };
        "luna.tailscale" = {
          hostname = "luna.tail1b8446.ts.net";
          user = "max";
          identityFile = "~/.ssh/id_github_felixmaximilian";
          identitiesOnly = true;
        };
        "*.ml *.kit" = {
          identityFile = "~/.ssh/yaak_gpu_cluster";
          forwardAgent = true;
          extraOptions = {
            AddKeysToAgent = "yes";
            UseKeychain = "yes";
            AddressFamily = "inet";
            Compression = "yes";
            ControlMaster = "auto";
            ControlPath = "~/.ssh/master-%r@%h:%p.socket";
            ControlPersist = "60m";
            RemoteForward = "9876 localhost:9876";
            LocalForward = "8080 localhost:8080";
          };
        };
        "*" = {
          serverAliveInterval = 60;
          serverAliveCountMax = 3;
          extraOptions.SetEnv = "TERM=xterm-256color";
        };
        "aboutblank.ml".hostname = "192.168.207.247";
        "renate.ml".hostname = "192.168.207.246";
        "berghain.ml".hostname = "192.168.207.244";
        "tresor.ml".hostname = "192.168.207.242";
        "sisyphos.ml".hostname = "192.168.207.241";
        "kitkat.ml".hostname = "192.168.207.239";
        "delta-dev1.kit".hostname = "192.168.144.35";
        "delta-emc1.kit".hostname = "172.30.0.40";
      };
      extraConfig = "ServerAliveInterval 120";
    };

    aerospace = {
      enable = true;
      launchd.enable = true;
      settings = {
        mode.main.binding = {
          alt-enter = "exec-and-forget open -n -a ghostty";
          alt-o = "exec-and-forget open -n -b com.google.Chrome";
          alt-q = "close --quit-if-last-window";
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";
          alt-h = "focus --boundaries all-monitors-outer-frame --boundaries-action stop left";
          alt-j = "focus --boundaries all-monitors-outer-frame --boundaries-action stop down";
          alt-k = "focus --boundaries all-monitors-outer-frame --boundaries-action stop up";
          alt-l = "focus --boundaries all-monitors-outer-frame --boundaries-action stop right";
          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";
          alt-shift-minus = "resize smart -50";
          alt-shift-equal = "resize smart +50";
          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          alt-6 = "workspace 6";
          alt-7 = "workspace 7";
          alt-8 = "workspace 8";
          alt-9 = "workspace 9";
          alt-0 = "workspace 10";
          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";
          alt-shift-5 = "move-node-to-workspace 5";
          alt-shift-6 = "move-node-to-workspace 6";
          alt-shift-7 = "move-node-to-workspace 7";
          alt-shift-8 = "move-node-to-workspace 8";
          alt-shift-9 = "move-node-to-workspace 9";
          alt-shift-0 = "move-node-to-workspace 10";
          alt-tab = "workspace-back-and-forth";
          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
          alt-shift-semicolon = "mode service";
        };
        mode.service.binding = {
          esc = [
            "reload-config"
            "mode main"
          ];
          r = [
            "flatten-workspace-tree"
            "mode main"
          ];
          f = [
            "layout floating tiling"
            "mode main"
          ];
          backspace = [
            "close-all-windows-but-current"
            "mode main"
          ];
          alt-shift-h = [
            "join-with left"
            "mode main"
          ];
          alt-shift-j = [
            "join-with down"
            "mode main"
          ];
          alt-shift-k = [
            "join-with up"
            "mode main"
          ];
          alt-shift-l = [
            "join-with right"
            "mode main"
          ];
        };
        workspace-to-monitor-force-assignment = {
          "1" = [
            "^PHL 346B1C$"
            "^DELL U2422H$"
            "^BenQ RD320U$"
            "built-in"
          ];
          "2" = [
            "^PHL 346B1C$"
            "^DELL U2422H$"
            "^BenQ RD320U$"
            "built-in"
          ];
          "3" = [
            "^PHL 346B1C$"
            "^BenQ RD320U$"
            "built-in"
          ];
          "4" = [
            "^PHL 346B1C$"
            "^BenQ RD320U$"
            "built-in"
          ];
          "5" = [
            "^PHL 346B1C$"
            "^BenQ RD320U$"
            "built-in"
          ];
          "6" = [
            "^PHL 346B1C$"
            "^BenQ RD320U$"
            "built-in"
          ];
          "7" = [ "built-in" ];
          "8" = [ "built-in" ];
          "9" = [ "built-in" ];
          "10" = [ "built-in" ];
        };
        on-window-detected = [
          {
            "if".app-id = "com.tinyspeck.slackmacgap";
            run = [ "move-node-to-workspace 9" ];
          }
          {
            "if".app-id = "com.spotify.client";
            run = [ "move-node-to-workspace 10" ];
          }
        ];
      };
    };

    ghostty.package = pkgs.ghostty-bin;
  };

  stylix.fonts.sizes.terminal = 14;
}
