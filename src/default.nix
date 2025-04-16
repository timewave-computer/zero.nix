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

      getOptionsMd = module:
        (pkgs.nixosOptionsDoc {
          inherit (pkgs.lib.evalModules {
            modules = [
              module
              suppressModuleArgsDocs
              {
                _module.args.pkgs = pkgs;
              }
            ];
            # specialArgs = { name = "nixos"; };
          }) options;
        }).optionsCommonMark;

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

      flakeModuleOptionsMd =
        lib.mapAttrs (name: module:
          (flake-parts-lib.mkFlake { inherit inputs; } {
            systems = [ system ];
            imports = [ "${inputs.flake-parts-website}/render/render-module.nix" ];
            perSystem.render.officialFlakeInputs = inputs;
            perSystem.render.inputs = {
              # render-module requires core flake-parts options to exist
              flake-parts = { title = ""; baseUrl = ""; intro = ""; getModules = _: []; };
              ${name} = {
                flake.flakeModules.${name} = module;
                title = "";
                sourcePath = ../flakeModules;
                baseUrl = "https://github.com/timewave-computer/zero.nix/blob/main";
                attributePath = [ "flakeModules" name ];
                intro = "";
              };
            };
          }).packages.${system}."generated-docs-${name}"
        ) self.flakeModules;
    in {
      packages.docs = stdenv.mkDerivation {

        version = "0.0.1";

        pname = "zero.nix-docs";

        src = ./.;

        nativeBuildInputs = [ mdbook mdbook-linkcheck python3 ];

        outputs = [ "out" ];

        buildPhase = ''
          mkdir -p reference/flake-modules
          mkdir -p reference/nixos-modules

          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: doc: ''
            cat ${doc}/options.md >> reference/flake-modules/${name}.md
          '') flakeModuleOptionsMd)}

          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: doc: ''
            cat ${doc} >> reference/nixos-modules/${name}.md
          '') nixosModuleOptionsMd)}

          mdbook build -d ./build
          cp -r ./build $out
          cp -r ./. $out/src
        '';

        installPhase = "true";
      };
    };
}
