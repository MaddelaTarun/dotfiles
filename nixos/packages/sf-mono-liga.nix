# Apple SF Mono patched with Nerd Fonts and Fira Code ligatures.
#
# Not in nixpkgs (Apple's licence keeps it out), and the upstream repo is not a
# flake, so flake.nix passes its source tree here as `src`.
{
  lib,
  stdenvNoCC,
  src,
}:

stdenvNoCC.mkDerivation {
  pname = "liga-sfmono-nerd-font";
  version = "2021-07-29";

  inherit src;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 -t "$out/share/fonts/opentype" ./*.otf
    runHook postInstall
  '';

  meta = with lib; {
    description = "SF Mono patched with Nerd Fonts and programming ligatures";
    homepage = "https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized";
    # Apple's SF Mono licence is not a free licence.
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
