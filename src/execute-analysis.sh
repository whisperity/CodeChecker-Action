#!/bin/bash
if [[ ! -z "$CODECHECKER_ACTION_DEBUG" ]]; then
  set -x
fi

echo "::group::Preparing for analysis"
if [[ -z "$COMPILATION_DATABASE" ]]; then
  echo "::error title=Internal error::environment variable 'COMPILATION_DATABASE' missing!"
  exit 1
fi

OUTPUT_DIR="$IN_OUTPUT_DIR"
if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR=~/"$GITHUB_ACTION_NAME"_Results
fi

mkdir -pv "$(dirname $"OUTPUT_DIR")"

if [[ ! -z "$IN_CONFIGFILE" ]]; then
  CONFIG_FLAG_1="--config"
  CONFIG_FLAG_2=$IN_CONFIGFILE
  echo "Using configuration file \"$IN_CONFIGFILE\"!"
fi

if [[ "$IN_CTU" == "true" ]]; then
  CTU_FLAGS="--ctu --ctu-ast-mode load-from-pch"
  echo "::notice title=Cross Translation Unit analyis::CTU has been enabled, the analysis might take a long time!"
fi
echo "::endgroup::"

"$CODECHECKER_PATH"/CodeChecker analyzers \
  --detail \
  || true

echo "::group::Executing Static Analysis"
# Note: Ignoring the result of the analyze command in CTU mode, as we do not
# wish to break the build on a CTU failure.
"$CODECHECKER_PATH"/CodeChecker analyze \
    "$COMPILATION_DATABASE" \
    --output "$OUTPUT_DIR" \
    --jobs $(nproc) \
    $CONFIG_FLAG_1 $CONFIG_FLAG_2 \
    $CTU_FLAGS \
  || [[ "$IN_CTU" == "true" ]]
EXIT_CODE=$?
echo "::endgroup::"

echo "::set-output name=OUTPUT_DIR::$OUTPUT_DIR"
exit $EXIT_CODE
