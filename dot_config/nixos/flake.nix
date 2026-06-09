{
  description = "My NixOS System Flake with Formatter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nixpkgs, nix-cachyos-kernel, ... }@inputs:
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
            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [
                  nix-cachyos-kernel.overlays.pinned
                ];

              }
            )

            ./configuration.nix
            ./hardware-configuration.nix
          ];
        };
      };

      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
