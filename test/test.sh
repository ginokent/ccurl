#!/bin/bash

set -E -e -u -o pipefail

export  pipe_debug="exec awk \"{print \\\"\\\\033[0;34m\$(date +%Y-%m-%dT%H:%M:%S%z) [ debug] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&  debugln () { test "${DEBUG:-true}" != true || echo "${*:?"log content"}" | sh -c "${pipe_debug:?}"  1>&2; }
export   pipe_info="exec awk \"{print \\\"\\\\033[0;36m\$(date +%Y-%m-%dT%H:%M:%S%z) [  info] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&   infoln () { echo "${*:?"log content"}" | sh -c "${pipe_info:?}"   1>&2; }
export     pipe_ok="exec awk \"{print \\\"\\\\033[0;32m\$(date +%Y-%m-%dT%H:%M:%S%z) [    ok] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&     okln () { echo "${*:?"log content"}" | sh -c "${pipe_ok:?}"     1>&2; }
export   pipe_warn="exec awk \"{print \\\"\\\\033[0;33m\$(date +%Y-%m-%dT%H:%M:%S%z) [  warn] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&   warnln () { echo "${*:?"log content"}" | sh -c "${pipe_warn:?}"   1>&2; }
export  pipe_error="exec awk \"{print \\\"\\\\033[0;31m\$(date +%Y-%m-%dT%H:%M:%S%z) [ error] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&  errorln () { echo "${*:?"log content"}" | sh -c "${pipe_error:?}"  1>&2; }
export  pipe_fatal="exec awk \"{print \\\"\\\\033[1;31m\$(date +%Y-%m-%dT%H:%M:%S%z) [ error] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&  fatalln () { echo "${*:?"log content"}" | sh -c "${pipe_fatal:?}"  1>&2; }

if test ! "${BASH_VERSINFO[0]}" -ge 3; then errorln "bash 3.x or later is required"; exit 1; fi

# var
REPO_ROOT=$(git rev-parse --show-toplevel)
CCURL="${REPO_ROOT:?}/bin/ccurl"

test_200 () { (
  test_cmd=("${CCURL}" https://httpbin.org/status/200)
  infoln "TEST: ${test_cmd[*]}"
  assert="\^\[\[0;32m"
  actual=$("${test_cmd[@]}" 2>&1 | grep -v "\[ debug\] .*curl " | cat -e)
  debugln "ASSERT" && debugln "${assert:?}"
  debugln "ACTUAL" && debugln "${actual:?}"
  if echo "${actual:?}" | grep -q "${assert:?}"; then
    okln "PASS: ${test_cmd[*]}"
  else
    errorln "FAIL: ${test_cmd[*]}"
  fi
)} && test_200

test_301 () { (
  test_cmd=("${CCURL}" https://httpbin.org/status/301)
  infoln "TEST: ${test_cmd[*]}"
  assert="\^\[\[0;33m"
  actual=$("${test_cmd[@]}" 2>&1 | grep -v "\[ debug\] .*curl " | cat -e)
  debugln "ASSERT" && debugln "${assert:?}"
  debugln "ACTUAL" && debugln "${actual:?}"
  if echo "${actual:?}" | grep -q "${assert:?}"; then
    okln "PASS: ${test_cmd[*]}"
  else
    errorln "FAIL: ${test_cmd[*]}"
  fi
)} && test_301

test_400 () { (
  test_cmd=("${CCURL}" https://httpbin.org/status/400)
  infoln "TEST: ${test_cmd[*]}"
  assert="\^\[\[0;31m"
  actual=$("${test_cmd[@]}" 2>&1 | grep -v "\[ debug\] .*curl " | cat -e)
  debugln "ASSERT" && debugln "${assert:?}"
  debugln "ACTUAL" && debugln "${actual:?}"
  if echo "${actual:?}" | grep -q "${assert:?}"; then
    okln "PASS: ${test_cmd[*]}"
  else
    errorln "FAIL: ${test_cmd[*]}"
  fi
)} && test_400

