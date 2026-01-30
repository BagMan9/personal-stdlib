{
  description = "Personal stdlib - packages, libraries, and utilities";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      # Custom library functions (system-independent)
      lib = import ./lib { inherit (nixpkgs) lib; };

      # Auto-import all packages from pkgs/
      # Each subdirectory with a default.nix returns { source, package }
      # where source is pure data and package is a callable for callPackage
      importPackages =
        pkgs: dir:
        let
          contents = builtins.readDir dir;
          isPackage = name: type: type == "directory" && builtins.pathExists (dir + "/${name}/default.nix");
          packageNames = nixpkgs.lib.filterAttrs isPackage contents;
          imported = nixpkgs.lib.mapAttrs (name: _: import (dir + "/${name}")) packageNames;
        in
        {
          packages = nixpkgs.lib.mapAttrs (name: pkg: pkgs.callPackage pkg.package { }) imported;
          sources = nixpkgs.lib.mapAttrs (name: pkg: pkg.source) imported;
        };

    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        imported = importPackages pkgs ./pkgs;
      in
      {
        packages = imported.packages // {
          default = pkgs.linkFarm "stdlib-all" (
            nixpkgs.lib.mapAttrsToList (name: drv: {
              inherit name;
              path = drv;
            }) imported.packages
          );
        };

        # Sources as pure data - evaluable without instantiating derivations
        inherit (imported) sources;

        # Dev shell for working on packages in this repo
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixpkgs-fmt
            nix-prefetch-git
            nix-prefetch-github
          ];
        };
      }
    )
    // {
      # System-independent outputs
      lib = lib;

      overlays.default = final: prev: {
        stdlib = self.packages.${prev.system};
      };

      # # Templates for quickly adding new packages
      # templates = {
      #   package = {
      #     path = ./templates/package;
      #     description = "New package template";
      #   };
      # };
    };
}
