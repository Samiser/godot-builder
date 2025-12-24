{
  description = "Godot game building library";

  outputs = _: {
    lib = {
      buildGodotWebGame = {
        pkgs,
        pname,
        version,
        src,
        exportPreset ? "main",
        itchTarget ? null,
      }: let
        godotVersion = builtins.replaceStrings ["-"] ["."] pkgs.godot_4.version;
      in {
        package = pkgs.stdenv.mkDerivation {
          inherit pname version src;

          nativeBuildInputs = with pkgs; [
            godot_4
            godotPackages.export-templates-bin
            zip
          ];

          buildPhase = ''
            export HOME=$TMPDIR

            # Set up Godot export templates
            mkdir -p $HOME/.local/share/godot/export_templates/${godotVersion}
            ln -s ${pkgs.godotPackages.export-templates-bin}/share/godot/export_templates/${godotVersion}/* \
              $HOME/.local/share/godot/export_templates/${godotVersion}/

            # Create output directory
            mkdir -p $out/build

            # Export the game
            godot --path . --export-release --headless "${exportPreset}" $out/build/index.html
          '';

          installPhase = ''
            cd $out/build
            zip -r $out/game.zip .
            mkdir -p $out/share
            cp -r . $out/share/game
          '';

          meta = with pkgs.lib; {
            description = "Web build of ${pname}";
            platforms = platforms.all;
          };
        };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            godot_4
            godotPackages.export-template
            butler
          ];

          shellHook = pkgs.lib.optionalString (itchTarget != null) ''
            alias publish='butler push $(nix build --print-out-paths --no-link)/game.zip ${itchTarget}:html'
          '';
        };
      };
    };
  };
}
