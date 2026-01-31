{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

mkShell rec {
  packages = with pkgs; [
    (pkgs.fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
      "llvm-tools-preview"
      "rustc-codegen-cranelift-preview"
    ])
    rust-analyzer-nightly
    cargo-llvm-cov
    cargo-nextest
    cargo-mutants
    cargo-watch
    cargo-audit
    cargo-deny
    grcov
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gcc
    mold
  ];
  LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

  # See https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/3?u=samuela. for more details.
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";  
}
