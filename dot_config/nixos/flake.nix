{
  description = "My NixOS System Flake with Formatter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # 1. Your System Configuration
      nixosConfigurations = {
        "nixos" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
          ];
        };
      };

      # 2. Your System Formatter (makes 'nix fmt' work in this directory)
      formatter.${system} = pkgs.nixpkgs-fmt; # or pkgs.alejandra if you prefer
    };
}
