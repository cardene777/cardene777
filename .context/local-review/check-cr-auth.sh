#!/bin/bash
/opt/homebrew/bin/coderabbit auth status 2>&1 | sed 's/\x1b\[[0-9;]*[mGKHJ]//g' | tr -d '\r' | grep -v '^[[:space:]]*$' | tail -10
