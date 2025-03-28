{
  description = "Nix flake for ODBC drivers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
      packages = rec {
        db2-odbc-driver-11-5-9 = pkgs.callPackage ./packages/db2.nix {
          inherit pkgs;
          specialArgs = {
            version = "11.5.9";
          };
        };
        db2-odbc-driver-12-1-0 = pkgs.callPackage ./packages/db2.nix {
          inherit pkgs;
          specialArgs = {
            version = "12.1.0";
          };
        };
        db2-odbc-driver-12-1-1 = pkgs.callPackage ./packages/db2.nix {
          inherit pkgs;
          specialArgs = {
            version = "12.1.1";
          };
        };
        db2-odbc-driver = db2-odbc-driver-11-5-9;
        postgres-odbc-driver = pkgs.callPackage ./packages/postgres.nix {
          inherit pkgs;
        };
        # broken with latest updates
        # mariadb-odbc-driver = pkgs.callPackage ./packages/mariadb.nix {
        #   inherit pkgs;
        # };
        default = postgres-odbc-driver;
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
        odbc-driver-pkgs = outputs.packages.${prev.system};
      };
    };
}
