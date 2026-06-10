{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    tree-sitter
    lua-language-server
    stylua
    ruff
    basedpyright
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}

