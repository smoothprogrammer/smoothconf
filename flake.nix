{
  description = "SmoothProgrammer's NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    ctools.url = "github:pinggirjurangstudio/ctools";
    ctools.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nix-darwin, ... }@inputs:
    {
      darwinConfigurations = {
        amartha = nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            username = "billyzaelanimalik";
            platform = "aarch64-darwin";
          };
          modules = [ ./configuration.nix ];
        };
      };
    };
}
