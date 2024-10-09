{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/packages/
  packages = [ pkgs.bun ];

  processes.live-preview.exec = "bun dev";
}
