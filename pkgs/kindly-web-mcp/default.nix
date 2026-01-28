{
  lib,
  python3Packages,
  fetchFromGitHub,
  brave,
}:

python3Packages.buildPythonPackage rec {
  pname = "kindly-web-mcp";
  version = "unstable-2026-01-27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Shelpuk-AI-Technology-Consulting";
    repo = "kindly-web-search-mcp-server";
    rev = "4bf285e072735aa67ecd9638969ed9e169565f71";
    hash = "sha256-YMZh3KEHudsGSWQjz0DXiZHDiVduZp7rg7WNgn40AvY=";
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
    brave
  ];

  makeWrapperArgs = [
    "--set"
    "KINDLY_BROWSER_EXECUTABLE_PATH"
    "${brave}/bin/brave"
  ];

  pythonImportsCheck = [ "kindly_web_search_mcp_server" ];

  meta = with lib; {
    description = "MCP server: Web search + robust content retrieval for AI coding tools";
    homepage = "https://github.com/Shelpuk-AI-Technology-Consulting/kindly-web-search-mcp-server";
    license = licenses.unfree;
    mainProgram = "kindly-web-search-mcp-server";
  };
}
