#!/bin/sh

# These ports correspond to any valid ports on the switch that we can query.
# They can be a arbitrary, but valid, ports because we only want to verify that
# we can retrieve the version number of the firmware on the PHYs. A sane return
# value is interpreted as functioning hardware.
PORT_NUMBER_1G=0
PORT_NUMBER_10G=25

# Counters for the number of tests ran, and number of failures encountered.
num_checks=0
num_failures=0

# Concatenate all of the error messages into one string for printing at the end.
failure_strings=""

echo "Checking status of devices..."

# Check the 1G PHY.
phy_version=$(echo "fw-version $PORT_NUMBER_1G" | phytool 2>&1)
if [ "$?" -ne 0 ]; then
  failure_strings=$failure_strings' 1G PHY test failed\n'
  num_failures=$(( $num_failures+1 ))
fi
num_checks=$(( $num_checks+1 ))

# Check the 10G PHY(s).
phy_version=$(echo "fw-version $PORT_NUMBER_10G" | phytool 2>&1)
if [ "$?" -ne 0 ]; then
  failure_strings=$failure_strings' 10G PHY test failed\n'
  num_failures=$(( $num_failures+1 ))
fi
num_checks=$(( $num_checks+1 ))

# Check the Prestera switch.
cpss_command=$(echo "do show version" | cpss_cmd)
cpss_version=$(echo $cpss_command |
               grep "CPSS version [0-9]\+\.[0-9]\+\.[0-9]\+" 2>&1)
if [ "$?" -ne 0 ]; then
  failure_strings=$failure_strings' Switch test failed\n'
  num_failures=$(( $num_failures+1 ))
fi
num_checks=$(( $num_checks+1 ))

# Check the modem.
modem_version_string=$(
    curl -X GET "http://127.0.0.1:8080/api/modem/version/api" 2>&1)
if [ "$?" -ne 0 ]; then
  failure_strings=$failure_strings' Glaukus (modem) failed\n'
  num_failures=$(( $num_failures+1 ))
else
  modem_version=$(echo $modem_version_string |
                  grep "\"chipType\":\".*\"[,}].*" 2>&1)
  if [ "$?" -ne 0 ]; then
    failure_strings=$failure_strings' Modem failed\n'
    num_failures=$(( $num_failures+1 ))
  fi
fi
num_checks=$(( $num_checks+1 ))

# Check the radio.
radio_version_string=$(
    curl -X GET "http://127.0.0.1:8080/api/radio/version" 2>&1)
if [ "$?" -ne 0 ]; then
  failure_strings=$failure_strings' Glaukus (radio) failed\n'
  num_failures=$(( $num_failures+1 ))
else
  radio_version=$(echo $radio_version_string |
                  grep "\"type\":\".*\"[,}].*" 2>&1)
  if [ "$?" -ne 0 ]; then
    failure_strings=$failure_strings' Radio failed\n'
    num_failures=$(( $num_failures+1 ))
  fi
fi
num_checks=$(( $num_checks+1 ))


# TODO(danielhira): Add tests for: xaui phy, k60, and soc.


# Print results
tests_result_string=""
if [ "$failure_strings" ]; then
  tests_result_string="found $num_failures failures."
else
  tests_result_string="all tests passed."
fi

echo "Ran $num_checks tests, $tests_result_string"
echo "$failure_strings"
