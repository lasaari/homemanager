{ config, lib, pkgs, ... }:
let 

  firefox-wrapped = pkgs.writeShellScriptBin "firefox" ''
           #!/bin/sh
           $(if type nixGL &> /dev/null; then echo "nixGL"; fi) ${pkgs.firefox}/bin/firefox $@
        '';
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lasse";
  home.homeDirectory = "/home/lasse";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.

  nixpkgs.config.allowUnfree = true;
  programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      enableCompletion = true;
      autocd = true;
      dotDir = ".config/zsh";
      shellAliases = {
          ll = "ls -lh";
          update = "sudo nix-channel --update && nix-channel --update && sudo nixos-rebuild switch && home-manager switch";
          cat = "bat";
        };
      plugins = with pkgs; [        

        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.5.0";
            sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
          };
        }

      ];

      initExtra = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source $HOME/.config/zsh/.p10k.zsh
      '';
    };


  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Terminal
    tmux
    zsh
    fzf
    zsh-powerlevel10k

    # Launcher
    sway-launcher-desktop
    
    # Browsers
    firefox-wrapped
    chromium

    # IDE
    neovim
    ripgrep
    tree-sitter

    # Dev tools
    gcc
    glibc.static
    nodejs-18_x
    
    # Utilities 
    keepassxc
    bat
    cloudflared

    # Fonts
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

  ];


  # Configure sway with dotfiles

  home.file.".config/sway" = {
      source = ./sway;
      recursive = true;
    };

  # Configure neovim with dotfiles

  home.file.".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };

  # Configure alacritty

  programs.alacritty = {
      enable = true;
      settings = {
          env.TERM = "xterm-256color";
          window = {

              decorations = "full";
            };
          font = {
            normal = {
              family = "FiraCode Nerd Font";
              style = "regular";
            };
            bold = {
              family = "FiraCode Nerd Font";
              style = "regular";
            };
            italic = {
              family = "FiraCode Nerd Font";
              style = "regular";
            };
            bold_italic = {
              family = "FiraCode Nerd Font";
              style = "regular";
            };
            size = 12.00;
        };
        shell = {
            program = ''${pkgs.zsh}/bin/zsh'';
          };
    };
    package =
      # Wrap alacritty with nixGL if exists
      pkgs.writeShellScriptBin "alacritty" ''
           #!/bin/sh

           $(if type nixGL &> /dev/null; then echo "nixGL"; fi) ${pkgs.alacritty}/bin/alacritty "$@"
        '';
  };
  xdg.enable = true;
  xdg.desktopEntries = {
    alacritty = {
      name = "Alacritty";
      genericName = "Terminal";
      exec = "alacritty";
      terminal = false;
      categories = [ "Application" "System" "TerminalEmulator" ];
      icon = ''${pkgs.alacritty}/share/icons/hicolor/scalable/apps/Alacritty.svg'';
    };
    firefox = {
        name = "Firefox Nix";
        genericName = "Browser";
        exec = "firefox %U";
        terminal = false;
        categories = [ "WebBrowser" "Network" ];
        icon = ''${pkgs.firefox}/share/icons/hicolor/128x128/apps/firefox.png'';
      };
  };


  # Variables
  home.sessionVariables = {
      EDITOR = "nvim";
      SHELL = ''${pkgs.zsh}/bin/zsh'';
      NIXPKGS_ALLOW_UNFREE = "1";
    };

  services.syncthing = {
    enable = true;
    # dataDir = "/home/lasse";
    # configDir = "/home/lasse/.config/syncthing";
    # user = "lasse";

  }; 
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


}
