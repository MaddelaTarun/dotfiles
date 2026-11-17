# Notwaita cursor themes (Black and White).
#
# Not in nixpkgs; upstream publishes prebuilt tarballs with index.theme and
# cursors/ at the top level. Installed under share/icons so both GTK and
# Xcursor find them by name (Notwaita-Black, Notwaita-White).
{
  lib,
  stdenvNoCC,
  fetchurl,
  xz,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "notwaita-cursor";
  version = "1.0.0-alpha1";

  srcs = [
    (fetchurl {
      url = "https://github.com/ful1e5/notwaita-cursor/releases/download/v${finalAttrs.version}/Notwaita-Black.tar.xz";
      hash = "sha256-P/F4NRBqz/6Ws9//qEKMYdqtfG5LdZa6jihqueZnx88=";
    })
    (fetchurl {
      url = "https://github.com/ful1e5/notwaita-cursor/releases/download/v${finalAttrs.version}/Notwaita-White.tar.xz";
      hash = "sha256-GhCfWI4x4pueJY2CUDRP0UGIPs72JRuoHPI4F33A0cg=";
    })
  ];

  nativeBuildInputs = [ xz ];

  dontConfigure = true;
  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/icons"
    for src in $srcs; do
      tar -xJf "$src" -C "$out/share/icons"
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "Notwaita cursor theme (Black and White variants)";
    homepage = "https://github.com/ful1e5/notwaita-cursor";
    license = licenses.lgpl3Plus;
    platforms = platforms.all;
  };
})
