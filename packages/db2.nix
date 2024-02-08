{
  pkgs,
  specialArgs ? {},
}: let
  defaultArgs = {
    pname = "db2-odbc-driver";
    version = "11.5.9";
  };
  args = defaultArgs // specialArgs;
in
  pkgs.stdenv.mkDerivation {
    pname = args.pname;
    version = args.version;
    src = ./.;

    nativeBuildInputs = pkgs.lib.optional pkgs.stdenv.isLinux [
      pkgs.libkrb5
      pkgs.autoPatchelfHook
    ];

    buildInputs =
      [
        pkgs.libxml2
        pkgs.pam
        pkgs.stdenv.cc.cc.lib
      ]
      # When using glibc >= 2.36 on linux need libxcrypt-legacy for libcrypt.so
      # https://github.com/NixOS/nixpkgs/issues/223805
      ++ pkgs.lib.optionals (pkgs.stdenv.isLinux) [
        pkgs.libxcrypt-legacy
      ]
      ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) [
        pkgs.libxcrypt
      ];

    # Ideally darwin would unpack the source dmg with something like undmg or hdiutil. Unfortunately
    # the Db2 image is signed which is not supported currently in undmg and hdiutil would require
    # the derivation to be impure.
    installPhase =
      if pkgs.stdenv.isDarwin
      then ''
        mkdir -p $out
        tar --extract \
          --gunzip \
          --file ./drivers/macos/ibm_data_server_driver_for_odbc_cli.tar.gz \
          --directory ./drivers
        cp -r ./drivers/clidriver/adm $out
        cp -r ./drivers/clidriver/bin $out
        cp -r ./drivers/clidriver/bnd $out
        cp -r ./drivers/clidriver/cfg $out
        cp -r ./drivers/clidriver/cfgcache $out
        cp -r ./drivers/clidriver/conv $out
        cp -r ./drivers/clidriver/db2dump $out
        cp -r ./drivers/clidriver/lib $out
        cp -r ./drivers/clidriver/license $out
        cp -r ./drivers/clidriver/msg $out
      ''
      else ''
        mkdir -p $out
        tar --extract \
          --gunzip \
          --file ./drivers/v11.5.9_linuxx64_dsdriver.tar.gz \
          --directory ./drivers
        tar --extract \
          --gunzip \
          --file ./drivers/dsdriver/odbc_cli_driver/linuxamd64/ibm_data_server_driver_for_odbc_cli.tar.gz \
          --directory ./drivers
        cp -r ./drivers/clidriver/adm $out
        cp -r ./drivers/clidriver/bin $out
        cp -r ./drivers/clidriver/cfg $out
        cp -r ./drivers/clidriver/cfgcache $out
        cp -r ./drivers/clidriver/conv $out
        cp -r ./drivers/clidriver/db2dump $out
        cp -r ./drivers/clidriver/lib $out
        cp -r ./drivers/clidriver/license $out
        cp -r ./drivers/clidriver/msg $out
        cp -r ./drivers/clidriver/properties $out
      '';
  }
