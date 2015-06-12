#!/bin/bash -i

#Change directory into the directory containing this script
cd "$(dirname "$(readlink -f "$0")")"

exec >>log/start.log
exec 2>&1

bundle exec rake assets:precompile assets:clean_expired
pkill -f foreman
RACK_ENV=production PORT=3000 bundle exec foreman start &
