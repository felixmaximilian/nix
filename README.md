# nix config

Flake-based config for macOS (nix-darwin + home-manager), Linux boxes, and
remote deploys to the `*.kit` hosts via deploy-rs.

## Local (macOS)

```bash
# home-manager: packages, shell, ghostty, aerospace config, ssh config, …
nh home switch ~/.config/nix
# fallback / explicit config name:
home-manager switch --flake ~/.config/nix#max@Maxs-Yaak-Device

# nix-darwin: system-level settings (config is named "mbp")
nh darwin switch ~/.config/nix
# fallback:
sudo darwin-rebuild switch --flake ~/.config/nix#mbp

# bootstrap on a fresh machine
nix run home-manager/master -- switch --flake github:felixmaximilian/nix#max@Maxs-Yaak-Device
sudo darwin-rebuild switch --flake github:felixmaximilian/nix#mbp
```

Home configurations: `max@Maximilians-MacBook-Air`, `max@Maxs-Yaak-Device`
(aarch64-darwin), `max@arch` (x86_64-linux), plus generic `x86_64-linux` /
`aarch64-linux` configs used by servers.

## Remote deploy: delta hosts (`*.kit`)

`deploy.nodes` defines `delta-emc1` (172.30.0.40) and `delta-dev1`
(192.168.144.35), both aarch64-linux, both deploying the generic
`aarch64-linux` home config as user `max`. `remoteBuild = true`: the closure
is built on the box — a darwin machine cannot build aarch64-linux derivations.

```bash
# one node
nix run github:serokell/deploy-rs -- ~/.config/nix#delta-emc1 --skip-checks
# all nodes
nix run github:serokell/deploy-rs -- ~/.config/nix --skip-checks

# verify: profile generation on the box
ssh delta-emc1.kit 'readlink ~/.local/state/nix/profiles/home'
```

Notes / pitfalls:

- `--skip-checks` is required: `nix flake check` would try to build
  cross-platform nodes on macOS and fail.
- Commit (or at least track) changes first — deploy evaluates the flake from
  git.
- The target needs `nix-daemon` resolvable on the **non-interactive** ssh
  PATH (`ssh <host> 'command -v nix-daemon'`). If missing, append
  `/nix/var/nix/profiles/default/bin` to `PATH` in `/etc/environment`.
- Long builds over a shared ssh ControlMaster can die with
  "Nix daemon disconnected unexpectedly" when the master breaks. Give the
  deploy a dedicated connection:

  ```bash
  nix run github:serokell/deploy-rs -- ~/.config/nix#delta-dev1 --skip-checks \
    --ssh-opts="-o ControlMaster=no -o ControlPath=none -o ServerAliveInterval=30"
  ```

- Fallback if ssh-ng keeps failing — build directly on the box:

  ```bash
  ssh delta-dev1.kit
  nix run home-manager -- switch --flake github:felixmaximilian/nix#aarch64-linux
  ```

## Cluster ssh (`*.ml`, `*.kit`)

Defined in `modules/home/darwin.nix` (`programs.ssh.settings`). All `*.ml`
and `*.kit` hosts share: `yaak_gpu_cluster` identity, agent forwarding, and
a ControlMaster (`auto`, persists 60 min after the last session), so repeat
connections are instant and port forwards are shared across sessions.

```bash
ssh renate.ml                 # any of: aboutblank renate berghain tresor sisyphos kitkat (.ml)
ssh delta-dev1.kit            # delta-dev1, delta-emc1 (.kit)
ssh -O check renate.ml        # is there a live master connection?
ssh -O exit  renate.ml        # kill master + all its forwards
```

## Port forwarding

No always-on forwards — attach them on demand to the master connection with
the nushell helpers from `modules/home/shared.nix`:

```nushell
fwd    renate.ml 8080             # local 8080 → remote 8080
fwd    delta-dev1.kit 18080 8080  # local 18080 → remote 8080 (no conflict with the above)
unfwd  renate.ml 8080             # release the local port

rfwd   renate.ml 9876             # reverse: remote 9876 → local 9876
unrfwd renate.ml 9876
```

`fwd`/`rfwd` start a background master (`ssh -fN`) if none exists. Forwards
are per-host, visible to every terminal/zellij session, and die with the
master (60 min after the last session closes). Plain `ssh -O forward -L/-R …`
does the same thing manually.

## Maintenance

```bash
nix flake update nixpkgs claude-code    # bump selected inputs
nix flake update                        # bump everything
nix fmt                                 # treefmt
nix flake check                         # formatting check (run on matching platform)
```
