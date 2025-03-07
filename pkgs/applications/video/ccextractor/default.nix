{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, cmake
, libiconv
, zlib
, enableOcr ? true
, makeWrapper
, tesseract4
, leptonica
, ffmpeg
}:

stdenv.mkDerivation rec {
  pname = "ccextractor";
  version = "0.91";

  src = fetchFromGitHub {
    owner = "CCExtractor";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-VqJQaYzH8psQJfnDariV4q7SkDiXRz9byR51C8DzVEs=";
  };

  sourceRoot = "source/src";

  nativeBuildInputs = [ pkg-config cmake makeWrapper ];

  buildInputs = [ zlib ]
    ++ lib.optional (!stdenv.isLinux) libiconv
    ++ lib.optionals enableOcr [ leptonica tesseract4 ffmpeg ];

  cmakeFlags = lib.optionals enableOcr [ "-DWITH_OCR=on" "-DWITH_HARDSUBX=on" ];

  postInstall = lib.optionalString enableOcr ''
    wrapProgram "$out/bin/ccextractor" \
      --set TESSDATA_PREFIX "${tesseract4}/share/"
  '';

  meta = with lib; {
    homepage = "https://www.ccextractor.org";
    description = "Tool that produces subtitles from closed caption data in videos";
    longDescription = ''
      A tool that analyzes video files and produces independent subtitle files from
      closed captions data. CCExtractor is portable, small, and very fast.
      It works on Linux, Windows, and OSX.
    '';
    platforms = platforms.unix;
    # undefined reference to `png_do_expand_palette_rgba8_neon'
    # undefined reference to `png_riffle_palette_neon'
    # undefined reference to `png_do_expand_palette_rgb8_neon'
    # undefined reference to `png_init_filter_functions_neon'
    # during Linking C executable ccextractor
    broken = stdenv.isAarch64;
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ titanous ];
  };
}
