{ self, inputs, flake-parts-lib, ... }:
{
  perSystem = { pkgs, system, ... }:
    let
      inherit (pkgs)
        lib
        mdbook
        mdbook-linkcheck
        python3
        stdenv;

      suppressModuleArgsDocs = { lib, ... }: {
          options = {
            _module.args = lib.mkOption {
              internal = true;
            };
          };
        };

      nixosModuleOptionsMd =
        lib.mapAttrs (name: module:
          (pkgs.nixosOptionsDoc {
            inherit (pkgs.lib.evalModules {
              modules = [
                module
                suppressModuleArgsDocs
                {
                  _module.args.pkgs = pkgs;
                  _module.check = false;
                }
              ];
              # specialArgs = { name = "nixos"; };
            }) options;
          }).optionsCommonMark
        ) self.nixosModules;

      docsFlake = flake-parts-lib.mkFlake { inherit inputs; } {
        systems = [ system ];
        imports = [ "${inputs.flake-parts-website}/render/render-module.nix" ];
        perSystem.render.officialFlakeInputs = inputs;
        perSystem.render.inputs =
          {
            # render-module requires core flake-parts options to exist
            flake-parts = { title = ""; baseUrl = ""; intro = ""; getModules = _: []; };
          }
          // (lib.mapAttrs (name: module: {
            flake.flakeModules.${name} = module;
            title = "";
            sourcePath = ../flakeModules/${name};
            baseUrl = "https://github.com/timewave-computer/zero.nix/blob/main";
            attributePath = [ "flakeModules" name ];
            intro = "";
          }) self.flakeModules);
      };

      flakeModuleOptionsMd = lib.mapAttrs
        (name: _: docsFlake.packages.${system}."generated-docs-${name}")
        self.flakeModules;

    in {
      packages.docs = stdenv.mkDerivation {

        version = "0.0.1";

        pname = "zero.nix-docs";

        src = ../.; # Include files from repo so they can be linked in mdbook

        nativeBuildInputs = [ mdbook mdbook-linkcheck python3 ];

        outputs = [ "out" ];

        buildPhase = ''
          cd docs

          mkdir -p reference/flake-modules
          mkdir -p reference/nixos-modules

          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: doc: ''
            cat ${doc}/options.md >> reference/flake-modules/${name}.md
          '') flakeModuleOptionsMd)}

          ${/*lib.concatStringsSep "\n" (lib.mapAttrsToList (name: doc: ''
            cat ${doc} >> reference/nixos-modules/${name}.md
          '') nixosModuleOptionsMd)*/"true"}

          mdbook build -d ./build
          cp -r ./build $out
          cp -r ./. $out/src
        '';

        installPhase = "true";
      };
    };
}
