{
  config,
  pkgs,
  stylix,
  llm-agents,
  claude-code,
  lumen,
  ...
}:
{
  imports = [ stylix.homeModules.stylix ];

  news.display = "silent";
  home = {
    stateVersion = "26.05";

    packages = with pkgs; [
      tig
      just
      dust
      ffmpeg
      ouch
      rsync
      age
      sops
      lumen.packages.${pkgs.stdenv.hostPlatform.system}.lumen
    ];

    sessionVariables = {
      EDITOR = "hx";
      NIXOS_OZONE_WL = "1";
    };
  };

  programs = {
    home-manager.enable = true;
    bat.enable = true;
    ripgrep.enable = true;
    skim.enable = true;
    zoxide.enable = true;
    uv.enable = true;
    bottom.enable = true;
    htop.enable = true;
    gh.enable = true;
    nix-your-shell.enable = true;
    carapace.enable = true;
    nh.enable = true;
    television.enable = true;
    fd.enable = true;
    delta.enable = true;

    codex = {
      enable = true;
      package = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
      settings = {
        model = "gpt-5.5";
        model_reasoning_effort = "xhigh";
        plan_mode_reasoning_effort = "xhigh";
        service_tier = "fast";
        personality = "pragmatic";
        approval_policy = "never";
        sandbox_mode = "danger-full-access";
        web_search = "live";
        suppress_unstable_features_warning = true;
        tui = {
          theme = "dracula";
          status_line = [
            "model-with-reasoning"
            "context-remaining"
            "current-dir"
            "git-branch"
            "five-hour-limit"
            "weekly-limit"
            "context-window-size"
            "used-tokens"
          ];
        };
        features = {
          apply_patch_freeform = true;
          fast_mode = true;
          multi_agent = true;
          remote_models = true;
          runtime_metrics = true;
          shell_snapshot = true;
          unified_exec = true;
        };
      };
    };

    claude-code = {
      enable = true;
      package = claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      settings = {
        user = {
          email = "felixmaximilian@gmail.com";
          name = "Max Moeller";
        };
        push.autoSetupRemote = true;
      };

      lfs.enable = true;
    };

    difftastic = {
      enable = true;
      git = {
        enable = true;
        diffToolMode = true;
      };
    };

    yazi = {
      enable = true;
      shellWrapperName = "f";
      plugins = {
        inherit (pkgs.yaziPlugins)
          full-border
          chmod
          starship
          git
          duckdb
          ouch
          rsync
          ;
      };
      settings = {
        plugin = {
          prepend_previewers =
            map
              (type: {
                run = "ouch";
                mime = "application/${type}";
              })
              [
                "*zip"
                "x-tar"
                "x-bzip2"
                "x-7z-compressed"
                "x-rar"
                "x-xz"
                "xz"
              ]
            ++
              map
                (type: {
                  run = "duckdb";
                  name = "*.${type}";
                })
                [
                  "csv"
                  "tsv"
                  "parquet"
                  "xlsx"
                  "db"
                  "duckdb"
                ];
        };

        prepend_preloaders =
          map
            (type: {
              run = "duckdb";
              name = "*.${type}";
              multi = false;
            })
            [
              "csv"
              "tsv"
              "json"
              "parquet"
              "txt"
              "xlsx"
            ];

      };
      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = "R";
              run = "plugin rsync";
              desc = "rsync";
            }
            {
              on = "H";
              run = "plugin duckdb -1";
              desc = "scroll one column to the left";
            }
            {
              on = "L";
              run = "plugin duckdb +1";
              desc = "scroll one column to the right";
            }
            {
              on = [
                "g"
                "o"
              ];
              run = "plugin duckdb -open";
              desc = "open with duckdb";
            }
            {
              on = [
                "g"
                "u"
              ];
              run = "plugin duckdb -ui";
              desc = "open with duckdb ui";
            }
          ];
        };

      };
      initLua = ''
        require("full-border"):setup {
          type = ui.Border.PLAIN,
        }
        require("starship"):setup()
        require("git"):setup()
        require("duckdb"):setup()
      '';
    };

    atuin = {
      enable = true;
      settings = {
        auto_sync = false;
        update_check = false;
        search_mode = "skim";
        search_mode_shell_up_key_binding = "skim";
        inline_height = 10;
        keymap_mode = "vim-insert";
      };
    };

    starship = {
      enable = true;
      settings.format = "$username$hostname$directory$git_branch$git_state$nix_shell$direnv$python\n$character";
    };

    nushell = {
      enable = true;
      shellAliases = {
        cx = "codex";
        zl = "zellij";
        gi = "gst-inspect-1.0";
        gl = "gst-launch-1.0";
      };
      environmentVariables = config.home.sessionVariables;
      settings = {
        show_banner = false;
      };
      # plugins = with pkgs.nushellPlugins; [
      # skim
      # polars
      # highlight
      # ];
      extraConfig = ''
        const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${pkgs.nu_scripts}/share/nu_scripts']

        use custom-completions/aerospace/aerospace-completions.nu *
        use custom-completions/docker/docker-completions.nu *
        use custom-completions/nix/nix-completions.nu *
        use custom-completions/git/git-completions.nu *
        use custom-completions/just/just-completions.nu *
        use custom-completions/pre-commit/pre-commit-completions.nu *
        use custom-completions/rg/rg-completions.nu *
        use custom-completions/ssh/ssh-completions.nu *
        use custom-completions/uv/uv-completions.nu *
        use custom-completions/zellij/zellij-completions.nu *
      '';
    };

    zellij = {
      enable = true;
      settings = {
        default_shell = "nu";
        simplified_ui = true;
        show_startup_tips = false;
        keybinds = {
          unbind = [
            "Ctrl h"
            "Ctrl n"
            "Ctrl o"
          ];

          "shared_except \"locked\" \"resize\"" = {
            bind = {
              _args = [ "Ctrl z" ];
              _children = [ { SwitchToMode._args = [ "resize" ]; } ];
            };
          };

          "shared_except \"locked\" \"move\"" = {
            bind = {
              _args = [ "Ctrl e" ];
              _children = [ { SwitchToMode._args = [ "move" ]; } ];
            };
          };

          "shared_except \"locked\" \"session\"" = {
            bind = {
              _args = [ "Ctrl s" ];
              _children = [ { SwitchToMode._args = [ "session" ]; } ];
            };
          };
        };
      };
    };

    helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        editor = {
          auto-save = true;
          true-color = true;
          idle-timeout = 0;
          auto-completion = true;
          path-completion = true;
          completion-timeout = 5;
          completion-trigger-len = 1;
          completion-replace = true;

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };

          statusline = {
            left = [
              "mode"
              "spinner"
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
            ];
            center = [ ];
            right = [
              "diagnostics"
              "version-control"
            ];
          };

          indent-guides = {
            render = true;
            skip-levels = 2;
          };

          soft-wrap = {
            enable = true;
          };

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          file-picker = {
            hidden = false;
          };
        };
        keys = {
          insert = {
            esc = [
              "collapse_selection"
              "normal_mode"
            ];
          };

          normal = {
            ";" = "command_mode";
            d = [
              "yank_joined_to_clipboard"
              "yank"
              "delete_selection"
            ];
            y = [
              "yank_joined_to_clipboard"
              "yank"
            ];
            C-h = "jump_view_left";
            C-j = "jump_view_down";
            C-k = "jump_view_up";
            C-l = "jump_view_right";
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
            space = {
              i = ":toggle lsp.display-inlay-hints";
            };
          };

          select = {
            j = [
              "extend_line_down"
              "extend_to_line_bounds"
            ];
            k = [
              "extend_line_up"
              "extend_to_line_bounds"
            ];
          };
        };
      };

      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter = {
              command = "${pkgs.nixfmt}/bin/nixfmt";
              args = [
                "--verify"
                "--strict"
              ];
            };
            language-servers = [
              "nixd"
              "statix"
            ];
          }
          {
            name = "python";
            auto-format = true;
            language-servers = [
              "ruff"
              "ty"
            ];
          }
          {
            name = "toml";
            auto-format = true;
          }
          {
            name = "yaml-config";
            scope = "source.yaml";
            grammar = "yaml";
            language-id = "yaml";
            file-types = [ { glob = "config/**/*.yaml"; } ];
            comment-token = "#";
            indent = {
              tab-width = 2;
              unit = "  ";
            };
            language-servers = [ "yaml-language-server" ];
          }
          {
            name = "yaml";
            auto-format = true;
            formatter = {
              command = "${pkgs.yamlfmt}/bin/yamlfmt";
              args = [ "-" ];
            };
          }
          {
            name = "just";
            auto-format = true;
          }
          {
            name = "nu";
            auto-format = true;
            language-servers = [ "nu-lsp" ];
            formatter = {
              command = "${pkgs.nufmt}/bin/nufmt";
              args = [ "--stdin" ];
            };
          }
          {
            name = "jq";
            auto-format = true;
            formatter = {
              command = "${pkgs.jqfmt}/bin/jqfmt";
              args = [
                "-ob"
                "-ar"
              ];
            };
          }
        ];

        language-server = {
          rust-analyzer = {
            config = {
              cargo.allFeatures = true;
              check.command = "clippy";
            };
          };

          ty = {
            command = "ty";
            args = [ "server" ];
            config = {
              experimental = {
                rename = true;
                autoImport = true;
              };
            };
          };

          ruff = {
            command = "ruff";
            args = [ "server" ];
            config.settings.format.preview = true;
          };

          clangd = {
            command = "${pkgs.clang-tools}/bin/clangd";
            args = [ "--clang-tidy" ];
          };

          nixd = {
            command = "${pkgs.nixd}/bin/nixd";
            args = [ "--semantic-tokens=true" ];
          };

          statix = {
            command = "${pkgs.efm-langserver}/bin/efm-langserver";
            config = {
              languages = {
                nix = [
                  {
                    lintCommand = "${pkgs.statix}/bin/statix check --stdin --format=errfmt";
                    lintStdIn = true;
                    lintIgnoreExitCode = true;
                    lintFormats = [ "<stdin>>%l:%c:%t:%n:%m" ];
                    rootMarkers = [
                      "flake.nix"
                      "shell.nix"
                      "default.nix"
                    ];
                  }
                ];
              };
            };
          };
        };
      };
      extraPackages = with pkgs; [
        tombi
        yaml-language-server
        vscode-json-languageserver
        just-lsp
        ruff
        ty
        rust-analyzer
        rustfmt
        clippy
        jq-lsp
      ];
    };
  };

  xdg.configFile = {
    "tig/config" = {
      enable = true;
      text = ''
        bind main R !git rebase -i %(commit)^
        bind diff R !git rebase -i %(commit)^
      '';
    };

    "helix/runtime/queries/yaml-config/highlights.scm" = {
      enable = true;
      text = ''
        ; inherits: yaml
      '';
    };

    "helix/runtime/queries/yaml-config/injections.scm" = {
      enable = true;
      text = ''
        ; inherits: yaml

        (block_mapping_pair
          key: (flow_node
            (plain_scalar
              (string_scalar) @_query))
          value: (block_node
            (block_scalar) @injection.content)
          (#eq? @_query "query")
          (#set! injection.language "sql"))

        (block_mapping_pair
          key: (flow_node
            (plain_scalar
              (string_scalar) @_query))
          value: (flow_node
            (plain_scalar
              (string_scalar) @injection.content))
          (#eq? @_query "query")
          (#set! injection.language "sql"))

        (block_mapping_pair
          key: (flow_node
            (plain_scalar
              (string_scalar) @_query))
          value: (flow_node
            [(double_quote_scalar) (single_quote_scalar)] @injection.content)
          (#eq? @_query "query")
          (#set! injection.language "sql"))

        (block_mapping_pair
          key: (flow_node
            (plain_scalar
              (string_scalar) @_hparams_jq))
          value: (block_node
            (block_scalar) @injection.content)
          (#eq? @_hparams_jq "hparams_jq")
          (#set! injection.language "jq"))

        (block_mapping_pair
          key: (flow_node
            (plain_scalar
              (string_scalar) @_hparams_jq))
          value: (flow_node
            (plain_scalar
              (string_scalar) @injection.content))
          (#eq? @_hparams_jq "hparams_jq")
          (#set! injection.language "jq"))

        (block_mapping_pair
          key: (flow_node
            (plain_scalar
              (string_scalar) @_hparams_jq))
          value: (flow_node
            [(double_quote_scalar) (single_quote_scalar)] @injection.content)
          (#eq? @_hparams_jq "hparams_jq")
          (#set! injection.language "jq"))
      '';
    };

    "helix/runtime/queries/yaml-config/textobjects.scm" = {
      enable = true;
      text = ''
        ; inherits: yaml
      '';
    };

    "helix/runtime/queries/yaml-config/indents.scm" = {
      enable = true;
      text = ''
        ; inherits: yaml
      '';
    };
  };

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/evenok-dark.yaml";
    fonts = {
      monospace = {
        package = pkgs.iosevka;
        name = "Iosevka";
      };
    };
    autoEnable = false;
    targets = {
      font-packages.enable = true;
      fontconfig.enable = true;
      helix.enable = true;
      nushell.enable = true;
      starship.enable = true;
      yazi.enable = true;
      zellij.enable = true;
    };
  };
}
