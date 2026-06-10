{ user, ... }:
{
  home.username = user;
  home.homeDirectory = "/home/${user}";

  # Stable SSH agent socket so multiplexed / zellij / tmux sessions don't end up
  # pointing at a torn-down forwarded socket. Forwarding negotiates a fresh
  # /tmp/ssh-XXXX/agent.N per connection; long-lived shells keep the old, dead
  # path. Re-point a stable symlink on every login and have shells read that.
  # Linux-only: on darwin SSH_AUTH_SOCK is the launchd keychain agent already.
  programs.nushell.extraEnv = ''
    let ssh_sock = ($env.HOME | path join ".ssh" "ssh_auth_sock")
    if ($env.SSH_AUTH_SOCK? | is-not-empty) and ($env.SSH_AUTH_SOCK != $ssh_sock) {
        ^ln -sf $env.SSH_AUTH_SOCK $ssh_sock
    }
    $env.SSH_AUTH_SOCK = $ssh_sock
  '';
}
