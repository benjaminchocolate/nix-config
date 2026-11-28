{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mupdf-headless
        qpdf
        texlab
        texliveFull
        tinymist
        typst

        pandoc
      ];
    };
}
