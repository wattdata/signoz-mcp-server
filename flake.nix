{
  description = "SigNoz MCP Server - Model Context Protocol server for SigNoz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          signoz-mcp-server = pkgs.buildGoModule {
            pname = "signoz-mcp-server";
            version = "0.0.4";

            src = ./.;

            vendorHash = "sha256-WIlOaITdKYJCBTAEZR6lH4OlX5JQGGH+DScYZRORXXA="; # Set to null to use vendor directory, or compute with `nix build` error

            subPackages = [ "cmd/server" ];

            postInstall = ''
              mv $out/bin/server $out/bin/signoz-mcp-server
            '';

            meta = with pkgs.lib; {
              description = "Model Context Protocol server for SigNoz observability platform";
              homepage = "https://github.com/SigNoz/signoz-mcp-server";
              license = licenses.mit;
              maintainers = [ ];
              mainProgram = "signoz-mcp-server";
            };
          };

          default = self.packages.${system}.signoz-mcp-server;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go_1_24
            gopls
            gotools
            go-tools
            goimports-reviser
          ];

          shellHook = ''
            echo "SigNoz MCP Server development environment"
            echo "Go version: $(go version)"
          '';
        };

        apps = {
          signoz-mcp-server = {
            type = "app";
            program = "${self.packages.${system}.signoz-mcp-server}/bin/signoz-mcp-server";
          };

          default = self.apps.${system}.signoz-mcp-server;
        };
      }
    );
}
