{
  self,
  lib,
  pkg-config,
  rustPlatform,
  clang,
  mold,
}:

rustPlatform.buildRustPackage {
  pname = "git-profile";
  version = self.shortRev or self.dirtyShortRev or "unknown";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src
      ./Cargo.toml
      ./Cargo.lock
    ];
  };

  cargoLock = {
    allowBuiltinFetchGit = true;
    lockFile = ./Cargo.lock;
  };

  strictDeps = true;

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    pkg-config
  ];

  buildInputs = [
    clang
    mold
  ];

  buildNoDefaultFeatures = true;

  postInstall = "";

  env = {
    RUSTFLAGS = "-Clinker=${clang}/bin/clang -Clink-arg=--ld-path=${mold}/bin/mold";
  };

  meta = {
    description = "A CLI tool to manage and easily switch between multiple git profiles";
    homepage = "https://github.com/takuma7/git-profile";
    license = lib.licenses.mit;
    mainProgram = "git-profile";
    platforms = lib.platforms.unix;
  };
}
