#!/usr/bin/env bash

set -e

export APP="$1"

FLAG="$2"

export CONFIG="apps/$APP/install.yaml"

if [ "$FLAG" == "-f" ]; then
	rm -f .state/$APP.skip
	echo "Deleted .state/$APP.skip"
fi

./install
