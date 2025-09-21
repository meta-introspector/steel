{
  description = "Embedded scheme interpreter in Rust";

  inputs = {
    flake-compat.url = "github:meta-introspector/flake-compat?ref=feature/CRQ-016-nixify";

    flake-parts = {
      url = "github:meta-introspector/flake-parts?ref=feature/CRQ-016-nixify";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    systems.url = "github:meta-introspector/default?ref=feature/CRQ-016-nixify";

    treefmt-nix = {
      url = "github:meta-introspector/treefmt-nix?ref=feature/CRQ-016-nixify";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.treefmt-nix.flakeModule ];

      systems = import inputs.systems;

      perSystem =
        { pkgs, self', ... }:
        {
          devShells.default = pkgs.callPackage ./nix/shell.nix { inherit (self'.packages) steel; };

          packages = {
            default = self'.packages.steel;
            steel = pkgs.callPackage ./nix/package.nix { };
          };

          treefmt = {
            flakeCheck = true;

            programs = {
              nixfmt.enable = true;
              rustfmt.enable = true;
            };

            projectRootFile = "flake.nix";
          };
        };
    };
}
