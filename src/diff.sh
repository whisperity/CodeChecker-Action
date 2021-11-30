#!/bin/bash
if [[ ! -z "$CODECHECKER_ACTION_DEBUG" ]]; then
  set -x
fi

echo "::group::Preparing for diff"

if [[ -z "$IN_DIFF_URL" ]]; then
  echo "::error title=Internal error::environment variable 'IN_DIFF_URL' missing!"
  exit 1
fi

if [[ -z "$PROJECT_PATH" ]]; then
  echo "::error title=Internal error::environment variable 'PROJECT_PATH' missing!"
  exit 1
fi

if [[ -z "$RAW_RESULT_DIR" ]]; then
  echo "::error title=Internal error::environment variable 'RAW_RESULT_DIR' missing!"
  exit 1
fi

if [[ -z "$CODECHECKER_DIFF_RUN_NAME" ]]; then
  echo "::error title=Internal error::environment variable 'CODECHECKER_DIFF_RUN_NAME' missing!"
  exit 1
fi

OUTPUT_DIR="$RAW_RESULT_DIR"_DiffHTML
OUTPUT_LOG="$(dirname "$RAW_RESULT_DIR")"/"$(basename "$RAW_RESULT_DIR")_Diff.log"
mkdir -pv "$(dirname "$OUTPUT_DIR")"

if [[ ! -z "$IN_CONFIGFILE" ]]; then
  CONFIG_FLAG_1="--config"
  CONFIG_FLAG_2=$IN_CONFIGFILE
  echo "Using configuration file \"$IN_CONFIGFILE\"!"
fi
echo "::endgroup::"

echo "::group::Generating HTML results from diff"
"$CODECHECKER_PATH"/CodeChecker \
  cmd diff \
  --new \
  --url "$IN_DIFF_URL" \
  --basename "$CODECHECKER_DIFF_RUN_NAME" \
  --newname "$RAW_RESULT_DIR" \
  --output html \
  --export "$OUTPUT_DIR" \
  $CONFIG_FLAG_1 $CONFIG_FLAG_2 \
  || true
echo "::set-output name=HTML_DIR::$OUTPUT_DIR"
echo "::endgroup::"

echo "::group::Printing diff results to log"
"$CODECHECKER_PATH"/CodeChecker \
  cmd diff \
  --new \
  --url "$IN_DIFF_URL" \
  --basename "$CODECHECKER_DIFF_RUN_NAME" \
  --newname "$RAW_RESULT_DIR" \
  $CONFIG_FLAG_1 $CONFIG_FLAG_2 \
  > "$OUTPUT_LOG"
EXIT_CODE=$?

cat "$OUTPUT_LOG"
echo "::set-output name=OUTPUT_LOG::$OUTPUT_LOG"
echo "::endgroup::"

if [[ $EXIT_CODE -eq 2 ]]; then
  echo "::set-output name=HAS_NEW_FINDINGS::true"

  # Let the job continue. If there were new results, the script may be breaking
  # the build in a later step. (After a potential upload to server.)
  EXIT_CODE=0
elif [[ $EXIT_CODE -eq 0 ]]; then
  echo "::set-output name=HAS_NEW_FINDINGS::false"
fi

# Exit code 1 is internal error of executing the step.
exit $EXIT_CODE
