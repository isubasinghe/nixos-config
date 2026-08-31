{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    system-manager = {
      url = "github:numtide/system-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    attic.url = "github:zhaofengli/attic";

    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-colors, llm-agents, system-manager, ... }@inputs:
    let
      inherit (self) outputs;
    in
    {
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/nixos
          ];
        };
        vb-100 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/vb-100
          ];
        };
        iso = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/iso.nix
          ];
        };
      };

      systemConfigs.precision-3591 = system-manager.lib.makeSystemConfig {
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/precision-3591
        ];
      };

      homeConfigurations = {
        "isithas@nixos" =
          let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
            unstable = import nixpkgs-unstable { inherit system; };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs outputs unstable; };
            modules = [
              ./home-manager/home.nix
            ];
          };
        "isithas@vb-100" =
          let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
            unstable = import nixpkgs-unstable { inherit system; };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs outputs unstable; };
            modules = [
              ./home-manager/home.nix
            ];
          };
        "isubasinghe@pop-os" =
          let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
            unstable = import nixpkgs-unstable { inherit system; };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs outputs unstable; };
            modules = [
              ./home-manager/home-pop-os.nix
            ];
          };
        "isubasinghe@precision-3591" =
          let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
            unstable = import nixpkgs-unstable { inherit system; };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs outputs unstable; };
            modules = [
              ./home-manager/home-precision-3591.nix
            ];
          };
      };
    };
}
