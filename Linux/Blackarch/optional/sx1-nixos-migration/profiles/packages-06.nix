{ lib, pkgs, ... }:

{
  # Additional packages matched by their upstream pname and build-validated.
  environment.systemPackages = map (path: lib.attrByPath path null pkgs) [
    [ "_3proxy" ] # 3proxy
    [ "botan3" ] # botan
    [ "cairomm_1_0" ] # cairomm
    [ "coin3d" ] # coin
    [ "docbook_xml_dtd_45" ] # docbook-xml
    [ "dump1090-fa" ] # dump1090
    [ "frei0r" ] # frei0r-plugins
    [ "geocode-glib_2" ] # geocode-glib
    [ "libcec_platform" ] # p8-platform
    [ "librdf_rasqal" ] # rasqal
    [ "libsigcxx" ] # libsigc++
    [ "libuchardet" ] # uchardet
    [ "memtest86plus" ] # memtest86+
    [ "nssmdns" ] # nss-mdns
    [ "pangomm_2_48" ] # pangomm
    [ "poppler_gi" ] # poppler-glib
    [ "soundwireserver" ] # soundwire
    [ "tinyxml-2" ] # tinyxml2
    [ "xercesc" ] # xerces-c
    [ "zoom-us" ] # zoom
  ];
}
