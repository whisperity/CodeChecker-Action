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

if [[ ! -z "$IN_ANALYZER_CONFIG" ]]; then
  ANALYZER_CONFIG_FLAG_1="--analyzer-config"
  ANALYZER_CONFIG_FLAG_2=$IN_ANALYZER_CONFIG
  echo "Using analyzer-config: \"$IN_ANALYZER_CONFIG\"!"
fi

if [[ ! -z "$IN_SKIPFILE" ]]; then
  SKIPFILE_FLAG_1="--skip"
  SKIPFILE_FLAG_2=$IN_SKIPFILE
  echo "Using skipfile: \"$IN_SKIPFILE\"!"
fi
echo "::endgroup::"

"$CODECHECKER_PATH"/CodeChecker analyzers \
  --detail \
  || true

echo "::group::Executing Static Analysis"
"$CODECHECKER_PATH"/CodeChecker analyze \
    "$COMPILATION_DATABASE" \
    --output "$OUTPUT_DIR" \
    --jobs $(nproc) \
    $CONFIG_FLAG_1 $CONFIG_FLAG_2 \
    $CTU_FLAGS \
    $ANALYZER_CONFIG_FLAG_1 $ANALYZER_CONFIG_FLAG_2 \
    $SKIPFILE_FLAG_1 $SKIPFILE_FLAG_2
EXIT_CODE=$?
echo "::endgroup::"

if [[ $EXIT_CODE -ne 0 && "$IN_IGNORE_CRASHES" == "true" ]]; then
  # In general it is a good idea not to destroy the entire job just because a
  # few translation units failed. Crashes are, unfortunately, usual.
  echo "::warning title=Static Analysis crashed on some inputs::Some of the analysis actions failed to conclude due to internal error in the analyser."
  EXIT_CODE=0
fi

echo "OUTPUT_DIR=$OUTPUT_DIR" >> "$GITHUB_OUTPUT"
exit $EXIT_CODE
