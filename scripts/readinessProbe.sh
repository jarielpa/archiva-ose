#!/bin/bash

until curl --silent --head --fail localhost:8080 > /dev/null; do
	sleep 2
done

exit 0