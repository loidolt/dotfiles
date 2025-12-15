{ pkgs, lib, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;

  # Map Nix system to opencode's naming convention
  opencodeSystem = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "darwin-x64";
    "aarch64-darwin" = "darwin-arm64";
  }.${system} or (throw "Unsupported system: ${system}");

  # Determine archive extension based on OS
  isLinux = pkgs.stdenv.isLinux;
  archiveExt = if isLinux then ".tar.gz" else ".zip";

  opencode = pkgs.stdenv.mkDerivation rec {
    pname = "opencode";
    version = "1.0.153";

    src = pkgs.fetchurl {
      url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-${opencodeSystem}${archiveExt}";
      sha256 = {
        "darwin-arm64" = "1jps2r5s1qm25lyy8g264i7x6mwjp3lr5v7i9cnpgr45qwidblpz";
        "linux-x64" = "04h9v2gsvl5ldfyapzhxw52sgyb0vv3l2f4fqr1rar56hpaahfds";
        # To add hashes for other platforms:
        # 1. Download the release: nix-prefetch-url https://github.com/sst/opencode/releases/download/v${version}/opencode-<platform>.{zip,tar.gz}
        # 2. Convert to base32: nix hash to-base32 <sha256-hex>
        # "darwin-x64" = "";
        # "linux-arm64" = "";
      }.${opencodeSystem} or (throw "Unsupported platform: ${opencodeSystem}. Only darwin-arm64 and linux-x64 are currently configured.");
    };

    nativeBuildInputs = [ pkgs.unzip ] ++ lib.optionals isLinux [ pkgs.gnutar pkgs.gzip ];

    unpackPhase = if isLinux then ''
      tar xzf $src
    '' else ''
      unzip $src
    '';

    installPhase = ''
      mkdir -p $out/bin

      # Find and install the opencode binary
      if [ -f opencode ]; then
        cp opencode $out/bin/opencode
      elif [ -f bin/opencode ]; then
        cp bin/opencode $out/bin/opencode
      else
        echo "Could not find opencode binary"
        find . -type f
        exit 1
      fi

      chmod +x $out/bin/opencode
    '';

    meta = with lib; {
      description = "OpenCode AI editor";
      homepage = "https://opencode.ai";
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      license = licenses.unfree;
    };
  };
in
{
  home.packages = [ opencode ];
}
