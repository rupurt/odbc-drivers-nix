{
  description = "Nix flake for ODBC drivers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      # use old version of nix packages that builds against glibc 2.35
      pkgs =
        import (builtins.fetchGit {
          name = "nixpkgs-with-glibc-2.35-224";
          url = "https://github.com/nixos/nixpkgs";
          ref = "refs/heads/nixpkgs-unstable";
          rev = "8ad5e8132c5dcf977e308e7bf5517cc6cc0bf7d8";
        }) {
          inherit system;
          overlays = [self.overlay];
        };
    in {
      # packages exported by the flake
      packages = {
        db2-odbc-driver = pkgs.db2-odbc-driver {};
        postgres-odbc-driver = pkgs.postgres-odbc-driver {};
        default = pkgs.postgres-odbc-driver {};
      };

      # nix fmt
      formatter = pkgs.alejandra;
    });
  in
    outputs
    // {
      # Overlay that can be imported so you can access the packages
      # using odbc-drivers-nix.overlay
      overlay = final: prev: {
        db2-odbc-driver = prev.pkgs.callPackage ./packages/db2.nix {};
        postgres-odbc-driver = prev.pkgs.callPackage ./packages/postgres.nix {};
        mongo-db-odbc-driver = prev.pkgs.callPackage ./packages/mongo-db.nix {};
      };
    };
}
