{ callPackage, fetchurl, dart }:
let
  mkFlutter = opts: callPackage (import ./flutter.nix opts) { };
  getPatches = dir:
    let files = builtins.attrNames (builtins.readDir dir);
    in map (f: dir + ("/" + f)) files;
  mkFlutterUrl = version: channel: "https://storage.googleapis.com/flutter_infra_release/releases/${channel}/linux/flutter_linux_${version}-${channel}.tar.xz";

  # Decouples flutter derivation from dart derivation,
  # use specific dart version to not need to bump dart derivation when bumping flutter.
  dartVersion = "2.16.1";
  dartSourceBase = "https://storage.googleapis.com/dart-archive/channels";
  mkDart = { version, channel, sha256 }: dart.override {
    inherit version;

    sources = {
      "${version}-x86_64-linux" = fetchurl {
        url = "${dartSourceBase}/${channel}/release/${version}/sdk/dartsdk-linux-x64-release.zip";
        inherit sha256;
      };
    };
  };

  dart-beta = mkDart {
    channel = "beta";
    version = "2.17.0-266.1.beta";
    sha256 = "sha256-r9UlJ5COIYQwGHPvIlLhPtPZk41HrP8mKXtFN20WXlE=";
  };
in {
  mkDart = mkDart;
  mkFlutter = mkFlutter;
  stable = mkFlutter rec {
    dart = mkDart {
      channel = "stable";
      version = dartVersion;
      sha256 = "sha256-PMY6DCFQC8XrlnFzOEPcwgBAs5/cAvNd78969Z+I1Fk=";
    };
    version = "2.10.1";
    pname = "flutter";
    src = fetchurl {
      url = mkFlutterUrl version "stable";
      sha256 = "sha256-rSfwcglDV2rvJl10j7FByAWmghd2FYxrlkgYnvRO54Y=";
    };
    patches = getPatches ./patches;
  };

  inherit dart-beta;
  beta = mkFlutter rec {
    dart = dart-beta;
    version = "2.13.0-0.1.pre";
    pname = "flutter";
    src = fetchurl {
      url = mkFlutterUrl version "beta";
      sha256 = "sha256-2JpKBTa1zkpdd1UuXfKBaXBr8Z+SNlDzENd92siFL0Q=";
    };
    patches = getPatches ./patches;
  };
}
