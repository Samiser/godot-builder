# Godot Builder

A Nix library for building and publishing Godot web games.

## Usage

Add to your game's `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    godot-builder.url = "github:samiser/godot-builder";
  };

  outputs = { nixpkgs, godot-builder, ... }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    games = forAllSystems (system:
      godot-builder.lib.buildGodotWebGame {
        pkgs = nixpkgs.legacyPackages.${system};
        pname = "my-game";
        version = "1.0.0";
        src = ./.;
        exportPreset = "main";
        itchTarget = "username/my-game";  # Optional
      }
    );
  in {
    packages = forAllSystems (system: {
      default = games.${system}.package;
    });

    devShells = forAllSystems (system: {
      default = games.${system}.devShell;
    });
  };
}
```

## Build and publish

```bash
# Build the game
nix build

# Enter dev shell (includes Godot and butler)
nix develop

# Publish to itch.io (if itchTarget is set)
export BUTLER_API_KEY="your-key"
publish
```

## Options

- `pname`: Package name
- `version`: Version string
- `src`: Source directory (usually `./`)
- `exportPreset`: Godot export preset name (default: `"main"`)
- `itchTarget`: itch.io target like `"username/game"` (optional)
