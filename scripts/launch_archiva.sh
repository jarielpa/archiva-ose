#!/bin/bash

$ARCHIVA_HOME/bin/scripts/generate_settings.py

$ARCHIVA_HOME/bin/scripts/create_admin_user.sh &

exec $ARCHIVA_HOME/bin/archiva console