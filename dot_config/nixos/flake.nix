{
  description = "My NixOS System Flake with Formatter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # 1. Your System Configuration
      nixosConfigurations = {
        "poldo" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
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
