{ stdenv

, meson
, ninja

, pkg-config
, vala

, glib
, gtk4
, libgee

, fabric-ui
}:

stdenv.mkDerivation {
  pname = "fabric.desktop.launcher";
  version = "0.1";

  src = ./.;

  buildInputs = [
    glib
    gtk4
    libgee
    fabric-ui
  ];

  nativeBuildInputs = [
    meson
    ninja

    pkg-config
    vala
  ];
}
