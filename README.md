# stdlib

Personal packages, libraries, and utilities.

## Adding a package

```bash
mkdir pkgs/my-new-thing
# copy from templates/package/default.nix or write from scratch
$EDITOR pkgs/my-new-thing/default.nix
```

That's it. The flake auto-discovers everything in `pkgs/`.

## Usage

### In another flake

```nix
{
  inputs.stdlib.url = "github:YOUR_USER/stdlib";
  # or path for local dev:
  # inputs.stdlib.url = "path:/path/to/stdlib";

  outputs = { self, nixpkgs, stdlib }: {
    # Direct package access
    packages.x86_64-linux.foo = stdlib.packages.x86_64-linux.some-tool;

    # Or use the overlay
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [{
        nixpkgs.overlays = [ stdlib.overlays.default ];
        # now pkgs.stdlib.some-tool is available
      }];
    };
  };
}
```

### Quick test

```bash
# Build a specific package
nix build .#example-tool

# Run it
nix run .#example-script

# List all packages
nix flake show

# Enter dev shell (has nix-prefetch-* tools)
nix develop
```

## Structure

```
.
├── flake.nix          # Auto-imports pkgs/, exposes overlay
├── lib/               # Custom nix helpers
├── pkgs/              # Each subdir with default.nix = package
│   ├── example-tool/
│   └── example-script/
└── templates/         # nix flake init -t .#package
```

## Library

Custom helpers live in `lib/`. Access them via `inputs.stdlib.lib.someHelper`.

## WIP packages

For half-finished stuff, just prefix the folder name with `_` or `wip-` and add a check in the flake to skip them, or keep them and let them fail - your call.
