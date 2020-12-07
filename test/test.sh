#!/usr/bin/env bash
set -E -e -u -o pipefail

export  pipe_debug="exec awk \"{print \\\"\\\\033[0;34m\$(date +%Y-%m-%dT%H:%M:%S%z) [ debug] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&  debugln () { [ "${LOG_SEVERITY:--1}" -gt 100 ] 2>/dev/null || echo "$*" | bash -c "${pipe_debug:?}"  1>&2; }
export   pipe_info="exec awk \"{print \\\"\\\\033[0;36m\$(date +%Y-%m-%dT%H:%M:%S%z) [  info] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&   infoln () { [ "${LOG_SEVERITY:--1}" -gt 200 ] 2>/dev/null || echo "$*" | bash -c "${pipe_info:?}"   1>&2; }
export pipe_notice="exec awk \"{print \\\"\\\\033[0;32m\$(date +%Y-%m-%dT%H:%M:%S%z) [notice] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" && noticeln () { [ "${LOG_SEVERITY:--1}" -gt 300 ] 2>/dev/null || echo "$*" | bash -c "${pipe_notice:?}" 1>&2; }
export   pipe_warn="exec awk \"{print \\\"\\\\033[0;33m\$(date +%Y-%m-%dT%H:%M:%S%z) [  warn] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&   warnln () { [ "${LOG_SEVERITY:--1}" -gt 400 ] 2>/dev/null || echo "$*" | bash -c "${pipe_warn:?}"   1>&2; }
export  pipe_error="exec awk \"{print \\\"\\\\033[0;31m\$(date +%Y-%m-%dT%H:%M:%S%z) [ error] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&  errorln () { [ "${LOG_SEVERITY:--1}" -gt 500 ] 2>/dev/null || echo "$*" | bash -c "${pipe_error:?}"  1>&2; }
export   pipe_crit="exec awk \"{print \\\"\\\\033[1;31m\$(date +%Y-%m-%dT%H:%M:%S%z) [  crit] \\\"\\\$0\\\"\\\\033[0m\\\"}\" /dev/stdin" &&   critln () { [ "${LOG_SEVERITY:--1}" -gt 600 ] 2>/dev/null || echo "$*" | bash -c "${pipe_crit:?}"   1>&2; }

if [ ! "${BASH_VERSINFO:-0}" -ge 3 ]; then printf '\033[1;31m%s\033[0m\n' "bash 3.x or later is required" 1>&2; exit 1; fi

# var
REPO_ROOT=$(git rev-parse --show-toplevel)
CCURL="${REPO_ROOT:?}/bin/ccurl"

# test
test_100 () { (
  test_cmd=("${CCURL}" https://httpbin.org/status/100)
  infoln "TEST: ${test_cmd[*]}"
  assert="\^\[\[0;36m"
  actual=$("${test_cmd[@]}" 2>&1 | grep -v "\[ debug\] .*curl " | cat -e)
  debugln "ASSERT" && debugln "${assert:?}"
  debugln "ACTUAL" && debugln "${actual:?}"
  if echo "${actual:?}" | grep -q "${assert:?}"; then
    noticeln "PASS: ${test_cmd[*]}"
  else
    errorln "FAIL: ${test_cmd[*]}"
  fi
)} && test_100

test_200 () { (
  test_cmd=("${CCURL}" https://httpbin.org/status/200)
  infoln "TEST: ${test_cmd[*]}"
  assert="\^\[\[0;32m"
  actual=$("${test_cmd[@]}" 2>&1 | grep -v "\[ debug\] .*curl " | cat -e)
  debugln "ASSERT" && debugln "${assert:?}"
  debugln "ACTUAL" && debugln "${actual:?}"
  if echo "${actual:?}" | grep -q "${assert:?}"; then
    noticeln "PASS: ${test_cmd[*]}"
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
    noticeln "PASS: ${test_cmd[*]}"
  else
    errorln "FAIL: ${test_cmd[*]}"
  fi
)} && test_301

test_404 () { (
  test_cmd=("${CCURL}" https://httpbin.org/status/404)
  infoln "TEST: ${test_cmd[*]}"
  assert="\^\[\[0;31m"
  actual=$("${test_cmd[@]}" 2>&1 | grep -v "\[ debug\] .*curl " | cat -e)
  debugln "ASSERT" && debugln "${assert:?}"
  debugln "ACTUAL" && debugln "${actual:?}"
  if echo "${actual:?}" | grep -q "${assert:?}"; then
    noticeln "PASS: ${test_cmd[*]}"
  else
    errorln "FAIL: ${test_cmd[*]}"
  fi
)} && test_404

test_500 () { (
  test_cmd=("${CCURL}" https://httpbin.org/status/500)
  infoln "TEST: ${test_cmd[*]}"
  assert="\^\[\[1;31m"
  actual=$("${test_cmd[@]}" 2>&1 | grep -v "\[ debug\] .*curl " | cat -e)
  debugln "ASSERT" && debugln "${assert:?}"
  debugln "ACTUAL" && debugln "${actual:?}"
  if echo "${actual:?}" | grep -q "${assert:?}"; then
    noticeln "PASS: ${test_cmd[*]}"
  else
    errorln "FAIL: ${test_cmd[*]}"
  fi
)} && test_500
