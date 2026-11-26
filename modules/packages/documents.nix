{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mupdf
        qpdf
        texlab
        texliveFull
        tinymist
        typst
      ];
    };
}
