{
  description = "A basic Nix flake that installs a few packages.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux =
      let 
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };
      in
        pkgs.buildEnv {
          name = "tools-env";
          paths = with pkgs; [
            curl
            jq
            yq
            kubectl
          ];
        };
  };
}
