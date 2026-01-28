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
      # Each subdirectory with a default.nix becomes a package
      importPackages =
        pkgs: dir:
        let
          contents = builtins.readDir dir;
          isPackage = name: type: type == "directory" && builtins.pathExists (dir + "/${name}/default.nix");
          packageNames = nixpkgs.lib.filterAttrs isPackage contents;
        in
        nixpkgs.lib.mapAttrs (name: _: pkgs.callPackage (dir + "/${name}") { }) packageNames;

    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        myPackages = importPackages pkgs ./pkgs;
      in
      {
        packages = myPackages // {
          default = pkgs.linkFarm "stdlib-all" (
            nixpkgs.lib.mapAttrsToList (name: drv: {
              inherit name;
              path = drv;
            }) myPackages
          );
        };

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
