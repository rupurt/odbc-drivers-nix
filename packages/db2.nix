{
  pkgs,
  specialArgs ? {},
}: let
  defaultArgs = {
    pname = "db2-odbc-driver";
    version = "11.5.9";
  };
  args = defaultArgs // specialArgs;
  sources = {
    aarch64-darwin = fetch "macos64" "sha256-kWpCYoLj6lqPBss8KXWWNNZIWkW0L3s9R86nIMb+T8Q=";
    x86_64-darwin = fetch "macos64" "sha256-kWpCYoLj6lqPBss8KXWWNNZIWkW0L3s9R86nIMb+T8Q=";
    x86_64-linux = fetch "linuxx64" "sha256-RClYjaKIIzNjFVav5l2EEtbejg9amdZGpxRecLITTZE=";
  };
  fetch = platform: sha256:
    pkgs.fetchurl {
      inherit sha256;
      url = "https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/v${args.version}/${platform}_odbc_cli.tar.gz";
    };
in
  pkgs.stdenv.mkDerivation {
    pname = args.pname;
    version = args.version;
    src = sources.${pkgs.stdenv.hostPlatform.system};

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
      # when using glibc >= 2.36 on linux need libxcrypt-legacy for libcrypt.so
      # https://github.com/NixOS/nixpkgs/issues/223805
      ++ pkgs.lib.optionals (pkgs.stdenv.isLinux) [
        pkgs.libxcrypt-legacy
      ]
      ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) [
        pkgs.libxcrypt
      ];

    installPhase = ''
      mkdir -p $out
      cp -r * $out
    '';
  }
