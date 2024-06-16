{
  description = "A flake that sets up a basic nix environment with all I want.";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    systems.url = "github:nix-systems/default";
    systems.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    systems,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    eachSystem = f:
      nixpkgs.lib.genAttrs (import systems) (
        system:
          f nixpkgs.legacyPackages.${system}
      );
  in {
    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Add development dependencies here
          git
          curl
          wget
          neovim
          tmux
          zsh
        ];
      };
    });

    homeConfigurations = eachSystem (pkgs: {
      mindblind = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          {
            home.username = "mindblind";
            home.homeDirectory = "/home/mindblind"; # Update this to your actual home directory path

            programs.neovim = {
              enable = true;
              # Add neovim configurations here if necessary
            };

            programs.tmux = {
              enable = true;
              # Add tmux configurations here if necessary
            };

            programs.zsh = {
              enable = true;
              # Add zsh configurations here if necessary
            };

            # Include your dotfiles
            home.activation.copyConfigs = {
              text = ''
                mkdir -p ~/.config
                cp -r ${./Configs}/* ~/.config/
              '';
            };
          }
        ];
      };
    });
  };

}