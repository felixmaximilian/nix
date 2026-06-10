{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable?shallow=1";
    nixpkgs-master.url = "github:nixos/nixpkgs/master?shallow=1";
    darwin = {
      url = "github:nix-darwin/nix-darwin?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew?shallow=1";

    llm-agents = {
      url = "github:numtide/llm-agents.nix?shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: https://github.com/NixOS/nixpkgs/pull/484661
    lumen = {
      url = "github:jnsahaj/lumen?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default?shallow=1";
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://claude-code.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };

  outputs =
    inputs@{
      self,
      darwin,
      nixpkgs,
      nixpkgs-master,
      home-manager,
      llm-agents,
      claude-code,
      lumen,
      stylix,
      treefmt-nix,
      systems,
      ...
    }:
    let
      user = "max";
      mkPkgs =
        { system }:
        let
          pkgsMaster = import nixpkgs-master {
            inherit system;
            config.allowUnfree = true;
          };
        in
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ (_: _prev: { inherit (pkgsMaster) chatgpt; }) ];
        };
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      darwinConfigurations = {
        mbp = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = inputs // {
            inherit user;
          };
          modules = [ ./modules/darwin.nix ];
        };
      };

      homeConfigurations = {
        "${user}@Maximilians-MacBook-Air" =
          let
            system = "aarch64-darwin";
            pkgs = mkPkgs { inherit system; };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit
                user
                llm-agents
                claude-code
                lumen
                stylix
                ;
            };
            modules = [
              ./modules/home/darwin.nix
              inputs."sops-nix".homeManagerModule
            ];
          };

        "${user}@Maxs-Yaak-Device" =
          let
            system = "aarch64-darwin";
            pkgs = mkPkgs { inherit system; };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit
                user
                llm-agents
                claude-code
                lumen
                stylix
                ;
            };
            modules = [
              ./modules/home/darwin.nix
              inputs."sops-nix".homeManagerModule
            ];
          };

        "${user}@arch" =
          let
            system = "x86_64-linux";
            pkgs = mkPkgs { inherit system; };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit
                user
                llm-agents
                claude-code
                lumen
                stylix
                ;
            };
            modules = [ ./modules/home/arch.nix ];
          };
      }
      // nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system:
        let
          pkgs = mkPkgs { inherit system; };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              user
              llm-agents
              claude-code
              lumen
              stylix
              ;
          };
          modules = [
            ./modules/home/shared.nix
            ./modules/home/linux.nix
          ];
        }
      );

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
      });
    };
}
