#!/bin/sh

sagesrvRun=1

while [ $sagesrvRun -eq 1 ]; do
	./sagesrv -l6 -m | logger -t z
done
