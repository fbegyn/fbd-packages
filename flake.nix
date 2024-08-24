{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    ...
  } @inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ devshell.overlays.default ];
      };
    in rec {
      devShells = rec {
        default = fbdPackages;
        fbdPackages = pkgs.devshell.mkShell rec {
          name = "fbd-packages";
          packages = [
            pkgs.aptly
            pkgs.nfpm
            pkgs.git
            pkgs.nix
            pkgs.curl
            pkgs.envsubst
          ];
          commands = [
            {
              name = "fbd-package:package";
              category = "package";
              help = "downloads the packages for the exporters";
              command = ''
                ./fbd-gh-package.sh
              '';
            }
          ];
        };
      };
    });
}
