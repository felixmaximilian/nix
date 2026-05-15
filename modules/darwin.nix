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
      "docker"
      "microsoft-teams"
      "sublime-text"
      "tailscale"
      "vnc-viewer"
    ];
    brews = [ "TeddyHuang-00/app/sshping" ];
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
  };
}
