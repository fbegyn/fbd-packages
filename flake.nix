{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in rec {
      devShells.default = pkgs.mkShell rec {
        buildInputs = [
          pkgs.aptly
          pkgs.nfpm
          pkgs.git
          pkgs.nix
          pkgs.curl
          pkgs.envsubst
          pkgs.busybox
        ];
        commands = [
          {
            name = "fbd-package:fetch";
            category = "download";
            help = "downloads the packages for the exporters";
            command = ''
            '';
          }
        ];
      };
    });
}
