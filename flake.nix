{
  description = "Calendar app for Nextcloud ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                self.overlays.default
              ];
            };

            phpPackages = pkgs.php85Packages;
          in
          f {
            inherit pkgs phpPackages;
          }
        );
    in
    {
      packages = forEachSupportedSystem (
        { pkgs, ... }:
        {
          default = pkgs.nextcloud-calendar;
        }
      );

      devShells = forEachSupportedSystem (
        { pkgs, ... }:
        {
          default = pkgs.mkShell {
            inputsFrom = [ pkgs.nextcloud-calendar ];
          };
        }
      );

      overlays.default = final: prev: {
        nextcloud-calendar =
          let
            php = final.php82;
          in
          final.buildNpmPackage (finalAttrs: {
            pname = "nextcloud-calendar";
            version = "6.3.0";

            npmDepsHash = "sha256-Lgt8fQJgGCJa31GTu0Vqd/2StQxV7sjl0pis5DnFWx0=";

            src = builtins.path {
              path = ./.;
              name = "source";
            };

            composerVendor = php.mkComposerVendor {
              inherit (finalAttrs) pname version src;
              composerStrictValidation = true;
              strictDeps = true;
              composerFlags = [
                "--no-dev"
                "-o"
              ];
              vendorHash = "sha256-GMknGBXIe1l59vNkqpe9OMzc7at/YuFrs+rR2VTrC1c=";
              postBuild = ''
                composer install --no-cache --no-interaction --no-progress --no-dev -o
              '';
            };

            buildPhase = ''
              npm run build
            '';

            installPhase = ''
              mkdir -p $out
              cp -r * $out/
              cp -r .* $out/

              cp -r $composerVendor/vendor $out/vendor
              chmod +w -R $out
              rm -rf $out/vendor/bin

              rm -rf $out/__mocks__
              rm -rf $out/.editorconfig
              rm -rf $out/.eslintrc.js
              rm -rf $out/.git
              rm -rf $out/.git-blame-ignore-revs
              rm -rf $out/.github
              rm -rf $out/.gitignore
              rm -rf $out/.gitlab-ci.yml
              rm -rf $out/.idea
              rm -rf $out/.nextcloudignore
              rm -rf $out/.php-cs-fixer.dist.php
              rm -rf $out/.php-cs-fixer.cache
              rm -rf $out/.scrutinizer.yml
              rm -rf $out/.stylelintignore
              rm -rf $out/.stylelintrc
              rm -rf $out/.tx
              rm -rf $out/babel.config.js
              rm -rf $out/build
              rm -rf $out/composer.json
              rm -rf $out/composer.lock
              rm -rf $out/coverage
              rm -rf $out/krankerl.toml
              rm -rf $out/COPYING
              rm -rf $out/Makefile
              rm -rf $out/node_modules
              rm -rf $out/package.json
              rm -rf $out/package-lock.json
              rm -rf $out/phpunit.unit.xml
              rm -rf $out/README.md
              rm -rf $out/phpunit*.xml
              rm -rf $out/psalm.xml
              rm -rf $out/renovate.json
              rm -rf $out/screenshots
              rm -rf $out/src
              rm -rf $out/stylelint.config.js
              rm -rf $out/tests
              rm -rf $out/timezones
              rm -rf $out/vendor/bin
              rm -rf $out/vendor/bamarni/composer-bin-plugin/e2e
              rm -rf $out/vendor-bin
              rm -rf $out/webpack.*
              rm -rf $out/playwright.config.js
              rm -rf $out/tsconfig.json
              rm -rf $out/tsconfig.json.license
              rm -rf $out/flake.nix
              rm -rf $out/flake.lock
            '';

            meta = {
              description = "Calendar app for Nextcloud";
              license = final.lib.licenses.agpl3Plus;
              homepage = "https://github.com/nextcloud/calendar";
              maintainers = [
                final.lib.maintainers.naxdy
              ];
            };
          });
      };
    };
}
