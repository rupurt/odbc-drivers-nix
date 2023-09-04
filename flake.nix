{
  description = "Nix flake for ODBC drivers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      };
    in {
      # packages exported by the flake
      packages = {
        db2-odbc-driver = pkgs.db2-odbc-driver {};
        postgres-odbc-driver = pkgs.postgres-odbc-driver {};
        mariadb-odbc-driver = pkgs.mariadb-odbc-driver {};
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
        mariadb-odbc-driver = prev.pkgs.callPackage ./packages/mariadb.nix {};
      };
    };
}
