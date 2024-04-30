#!/usr/bin/env bash

set -e

export APP=$1
export CONFIG="apps/$APP/install.yaml"
./install
