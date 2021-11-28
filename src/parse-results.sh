#!/bin/bash
set -x

if [[ -z "$PROJECT_PATH" ]]; then
  echo "::error title=Internal error::environment variable 'PROJECT_PATH' missing!"
  exit 1
fi

if [[ -z "$RAW_RESULT_DIR" ]]; then
  echo "::error title=Internal error::environment variable 'RAW_RESULT_DIR' missing!"
  exit 1
fi

OUTPUT_DIR="$IN_OUTPUT_DIR"
if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR=~/"$ACTION_NAME"_Results-HTML
fi
mkdir -pv "$(dirname $"OUTPUT_DIR")"

OUTPUT_LOG="$(dirname "$IN_OUTPUT_DIR")"/"$(basename "$IN_OUTPUT_DIR")_Parse.log"

if [[ ! -z "$IN_CONFIGFILE" ]]; then
  CONFIG_FLAG_1="--config"
  CONFIG_FLAG_2=$IN_CONFIGFILE
  echo "Using configuration file \"$IN_CONFIGFILE\"!"
fi

"$CODECHECKER_PATH"/CodeChecker parse \
  "$RAW_RESULT_DIR" \
  --export "html" \
  --output "$OUTPUT_DIR" \
  --trim-path-prefix "$PROJECT_PATH" \
  || true
echo "::set-output name=HTML_DIR::$OUTPUT_DIR"

"$CODECHECKER_PATH"/CodeChecker parse \
  "$RAW_RESULT_DIR" \
  --trim-path-prefix "$PROJECT_PATH" \
  > "$OUTPUT_LOG"
EXIT_CODE=$?
echo "::set-output name=OUTPUT_LOG::$OUTPUT_LOG"


if [[ "$EXIT_CODE" == "2" ]]; then
  echo "::set-output name=HAS_FINDINGS::true"

  if [[ "$IN_FAIL_IF_REPORTS" == "true" ]]; then
    echo "::notice title=Static analysis suppressed::CodeChecker static analyser found bug reports, but the build job is configured to suppress it."
  fi

  # Let the jobs continue. If there were failures, the action script will break
  # the build in a later step. (After a potential upload to server.)
  EXIT_CODE=0
else
  echo "::set-output name=HAS_FINDINGS::false"
fi

exit $EXIT_CODE
