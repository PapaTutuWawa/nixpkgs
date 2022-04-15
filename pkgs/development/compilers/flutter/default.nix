{ callPackage, fetchurl, dart }:
let
  mkFlutter = opts: callPackage (import ./flutter.nix opts) { };
  getPatches = dir:
    let files = builtins.attrNames (builtins.readDir dir);
    in map (f: dir + ("/" + f)) files;
  version = "2.10.4";
  channel = "stable";
  filename = "flutter_linux_${version}-${channel}.tar.xz";

  # Decouples flutter derivation from dart derivation,
  # use specific dart version to not need to bump dart derivation when bumping flutter.
  dartVersion = "2.16.2";
  dartSourceBase = "https://storage.googleapis.com/dart-archive/channels";
  dartForFlutter = dart.override {
    version = dartVersion;
    sources = {
      "${dartVersion}-x86_64-linux" = fetchurl {
        url = "${dartSourceBase}/stable/release/${dartVersion}/sdk/dartsdk-linux-x64-release.zip";
        sha256 = "sha256-egrYd7B4XhkBiHPIFE2zopxKtQ58GqlogAKA/UeiXnI=";
      };
    };
  };
in {
  mkFlutter = mkFlutter;
  stable = mkFlutter rec {
    inherit version;
    dart = dartForFlutter;
    pname = "flutter";
    src = fetchurl {
      url = "https://storage.googleapis.com/flutter_infra_release/releases/${channel}/linux/${filename}";
      sha256 = "sha256-etdpaQ8aD9HkMsfUwmXrqUYjeqlCQd5bU/kv8x3cgtI=";
    };
    patches = getPatches ./patches;
  };
}
