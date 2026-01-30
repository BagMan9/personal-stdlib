let
  source = {
    owner = "Shelpuk-AI-Technology-Consulting";
    repo = "kindly-web-search-mcp-server";
    rev = "4bf285e072735aa67ecd9638969ed9e169565f71";
    hash = "sha256-YMZh3KEHudsGSWQjz0DXiZHDiVduZp7rg7WNgn40AvY=";
    version = "unstable-2026-01-27";
  };
in
{
  inherit source;

  package =
    {
      lib,
      python3Packages,
      fetchFromGitHub,
      google-chrome,
    }:

    python3Packages.buildPythonPackage {
      pname = "kindly-web-mcp";
      inherit (source) version;
      pyproject = true;

      src = fetchFromGitHub {
        inherit (source)
          owner
          repo
          rev
          hash
          ;
      };

      build-system = with python3Packages; [
        hatchling
      ];

      dependencies = with python3Packages; [
        mcp
        pydantic
        httpx
        beautifulsoup4
        markdownify
        nodriver
        pymupdf
      ];

      buildInputs = [
        google-chrome
      ];

      patches = [
        ./fix-nix-subprocess-pythonpath.patch
      ];

      makeWrapperArgs = [
        "--set"
        "KINDLY_BROWSER_EXECUTABLE_PATH"
        "${lib.getExe google-chrome}"
      ];

      pythonImportsCheck = [
        "nodriver"
        "kindly_web_search_mcp_server"
      ];

      meta = with lib; {
        description = "MCP server: Web search + robust content retrieval for AI coding tools";
        homepage = "https://github.com/Shelpuk-AI-Technology-Consulting/kindly-web-search-mcp-server";
        license = licenses.unfree;
        mainProgram = "kindly-web-search-mcp-server";
      };
    };
}
