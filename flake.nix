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
      packages = rec {
        db2-odbc-driver = pkgs.callPackage ./packages/db2.nix {
          inherit pkgs;
        };
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
