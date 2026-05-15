{
  self,
  pkgs,
  user,
  nix-homebrew,
  ...
}:
{
  imports = [ nix-homebrew.darwinModules.nix-homebrew ];

  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ user ];
  };

  nixpkgs.config.allowUnfree = true;
  system = {
    primaryUser = user;
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;

    defaults = {
      dock = {
        tilesize = 40;
      };

      finder = {
        ShowStatusBar = true;
        FXPreferredViewStyle = "Nlsv";
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false;
        KeyRepeat = 2;
        InitialKeyRepeat = 25;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    nushell
  ];

  environment.systemPackages = with pkgs; [ nextdns ];

  users.users."${user}" = {
    home = "/Users/${user}";
    shell = pkgs.nushell;
  };

  nix-homebrew = {
    inherit user;
    enable = true;
    enableRosetta = true;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    greedyCasks = true;
    casks = [
      "tunnelblick"
      "cloudflare-warp"
      "netron"
      "signal"
      "uhk-agent"
      "spotify"
      "display-pilot"
      "alfred"
      "discord"
      "docker"
      "meetingbar"
      "microsoft-teams"
      "obsidian"
      "sublime-text"
      "tailscale"
      "visual-studio-code"
      "vnc-viewer"
      "zoom"
    ];
    brews = [ "TeddyHuang-00/app/sshping" ];
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
  };
}
