{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
};

  outputs = { self, nixpkgs, rust-overlay, ...}:
    let
      inherit (nixpkgs) lib;
      systems = lib.intersectLists lib.systems.flakeExposed lib.platforms.unix;
      forAllSystems = lib.genAttrs systems;

      nixpkgsFor = forAllSystems (system:
        import nixpkgs { inherit system; }
      );
    in

    {
      packages = forAllSystems (system: rec {
        git-profile = nixpkgsFor.${system}.callPackage ./package.nix { inherit self; };
        default = git-profile;
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          rust-bin = rust-overlay.lib.mkRustBin { } pkgs;
        in
        {
          default = pkgs.mkShell rec {
            packages = [
              (rust-bin.selectLatestNightlyWith (
                toolchain:
                toolchain.default.override {
                  extensions = [
                    # includes already:
                    # rustc
                    # cargo
                    # rust-std
                    # rust-docs
                    # rustfmt-preview
                    # clippy-preview
                    "rust-analyzer"
                    "rust-src"
                  ];
                }
              ))
              pkgs.cargo-insta
            ];

            nativeBuildInputs = [
              pkgs.rustPlatform.bindgenHook
              pkgs.pkg-config
            ];

            buildInputs = with pkgs; [
              mold
            ];

            LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
          };
        }
      );

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);
    };
}
