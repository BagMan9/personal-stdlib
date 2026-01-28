{ lib }:

rec {
  # Example: wrap a program with environment variables
  wrapWithEnv = { pkg, vars }: lib.warn "wrapWithEnv is a stub - implement me" pkg;

  # Example: generate a simple shell script package
  mkScript =
    {
      name,
      text,
      runtimeInputs ? [ ],
    }:
    lib.warn "mkScript is a stub - see pkgs/example-script for real implementation" null;

  # Example: common meta attributes you reuse
  myMeta = {
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
