#!/bin/bash
set -ex

if [[ ! -z "$IN_LOGFILE" && ! -z "$IN_COMMAND" ]]; then
  echo "::error title=Configuration error::'logfile' and 'build-command' both specified!"
  exit 1
fi

if [[ ! -z "$IN_LOGFILE" ]]; then
  # Pretty trivial.
  cp -v "$IN_LOGFILE" "$OUT_FILE"
  exit $?
fi

if [[ ! -z "$IN_COMMAND" ]]; then
  "$CODECHECKER_PATH"/CodeChecker log \
    --build "$IN_COMMAND" \
    --output "$OUT_FILE"
  exit $?
fi

echo "::error title=Configuration error::neither 'logfile' nor 'build-command' specified!"
echo "[]" > "$OUT_FILE"
exit 1
