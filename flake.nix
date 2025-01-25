{
  description = "Development environment for Parlor";

  nixConfig.bash-prompt = "[nix-develop\:parlor] ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              erlang_27
              elixir_1_17
            ] ++ lib.optionals stdenv.isDarwin [
              darwin.apple_sdk.frameworks.CoreFoundation
              darwin.apple_sdk.frameworks.CoreServices
            ];
          };
        }
      );
}
