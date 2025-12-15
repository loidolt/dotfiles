{ pkgs, lib, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;

  # Map Nix system to Claude's naming convention
  claudeSystem = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "darwin-x64";
    "aarch64-darwin" = "darwin-arm64";
  }.${system} or (throw "Unsupported system: ${system}");

  claude = pkgs.stdenv.mkDerivation rec {
    pname = "claude";
    version = "2.0.69";

    src = pkgs.fetchurl {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/${claudeSystem}/claude";
      sha256 = {
        "darwin-arm64" = "08c35a12f0f29118f42240a19b5836cd39cf3db054c57cd540a9e2d43077bb4e";
        "darwin-x64" = "c69f584c56eb5c280468d6eb1948b40f21809064b3f6bcd1bf20c5bc142da411";
        "linux-x64" = "dd9857b0e2c9c0a7a966fb9a92af1c3494e12cf08aaddc441132c41a78902510";
        "linux-arm64" = "ae14d975dca38fb84e6872df622cf1f9f2b7edd2472be11d4e1103a6333eea24";
      }.${claudeSystem} or (throw "No hash for system: ${claudeSystem}");
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/claude
      chmod +x $out/bin/claude
    '';

    meta = with lib; {
      description = "Claude Code CLI - Official CLI for Claude";
      homepage = "https://claude.ai";
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      license = licenses.unfree;
    };
  };
in
{
  home.packages = [ claude ];
}
