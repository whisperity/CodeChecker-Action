#!/bin/bash
set -x

if [[ -z "$IN_STORE_URL" ]]; then
  echo "::error title=Internal error::environment variable 'IN_STORE_URL' missing!"
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

if [[ -z "$CODECHECKER_STORE_RUN_NAME" ]]; then
  echo "::error title=Internal error::environment variable 'CODECHECKER_STORE_RUN_NAME' missing!"
  exit 1
fi

if [[ ! -z "$IN_CONFIGFILE" ]]; then
  CONFIG_FLAG_1="--config"
  CONFIG_FLAG_2=$IN_CONFIGFILE
  echo "Using configuration file \"$IN_CONFIGFILE\"!"
fi

if [[ ! -z "$CODECHECKER_STORE_RUN_TAG" ]]; then
  RUN_TAG_FLAG_1="--tag"
  RUN_TAG_FLAG_2=$CODECHECKER_STORE_RUN_TAG
fi

"$CODECHECKER_PATH"/CodeChecker \
  store \
  "$RAW_RESULT_DIR" \
  --url "$IN_STORE_URL" \
  --name "$CODECHECKER_STORE_RUN_NAME" \
  --trim-path-prefix "$PROJECT_PATH" \
  $RUN_TAG_FLAG_1 $RUN_TAG_FLAG_2 \
  $CONFIG_FLAG_1 $CONFIG_FLAG_2