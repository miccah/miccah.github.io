{
  description = "miccah.io";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      newPost = pkgs.writeShellApplication {
        name = "new-post";
        text = ''
          if [ -z "''${1:-}" ]; then
            echo "usage: $(basename "$0") <post name>" >&2
            exit 1
          fi

          ts=$(date +'%Y-%m-%d')
          slug=$(tr '[A-Z] ' '[a-z]-' <<< "$1" | tr -dc '[a-z]-')
          filepath="$HOME/blog/content/posts/$ts-$slug.markdown"

          {
            echo '---'
            echo "date: ''${ts}T09:00:00Z"
            echo 'tags: misc'
            echo "title: $1"
            echo '---'
            echo
          } >> "$filepath"

          nvim "$filepath"
        '';
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          hugo
          newPost
        ];
      };
    };
}
