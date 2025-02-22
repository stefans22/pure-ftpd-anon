{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      initScript = pkgs.writeTextDir "/app/init.sh" (builtins.readFile ./init.sh);

      dockerImage = pkgs.dockerTools.buildImage {
        name = "pure-ftpd-anon";

        copyToRoot = pkgs.buildEnv {
          name = "root-layer";
          paths = [ pkgs.pure-ftpd pkgs.bash pkgs.coreutils pkgs.shadow initScript ];
          pathsToLink = [ "/bin" "/app" ];
        };

        config = {
          Entrypoint = [ "/bin/bash" "/app/init.sh" ];
          Volumes = {
            "/data" = {};
          };
          Ports = [ 21 30000 30001 30002 30003 30004 30005 ];
        };
      };
    in
    {
      defaultPackage.x86_64-linux = dockerImage;
    };
}
