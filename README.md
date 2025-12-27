# Godot Builder

A Nix library and GitHub Actions for building and publishing Godot web games.

## Nix Library

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

### Build and publish

```bash
# Build the game
nix build

# Enter dev shell (includes Godot and butler)
nix develop

# Publish to itch.io (if itchTarget is set)
export BUTLER_API_KEY="your-key"
publish
```

### Options

- `pname`: Package name
- `version`: Version string
- `src`: Source directory (usually `./`)
- `exportPreset`: Godot export preset name (default: `"main"`)
- `itchTarget`: itch.io target like `"username/game"` (optional)

## GitHub Actions

### Build Action

Builds your Godot game using Nix (for CI validation).

**`build/action.yml`:**

```yaml
name: Build

on:
  push:
    branches: [main]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: samiser/godot-builder/build@main
```

**Inputs:**

- `flake-target`: Nix flake target (default: `.#default`)

### Publish Action

Builds and publishes your game to itch.io.

**`publish/action.yml`:**

```yaml
name: Publish to itch.io

on:
  workflow_dispatch:

jobs:
  publish:
    runs-on: ubuntu-latest
    environment: butler # Optional: if using GitHub Environments
    steps:
      - uses: actions/checkout@v4
      - uses: samiser/godot-builder/publish@main
        with:
          itch-target: username/my-game:html
          butler-api-key: ${{ secrets.BUTLER_API_KEY }}
```

**Inputs:**

- `itch-target`: itch.io target in format `username/game:channel` (required)
- `butler-api-key`: Your itch.io API key (required, **use secrets**)
- `flake-target`: Nix flake target (default: `.#default`)

**Setup:**

1. Get your API key from https://itch.io/user/settings/api-keys
2. Add it as a
   [GitHub repository secret](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets#creating-secrets-for-a-repository)
   named `BUTLER_API_KEY`
