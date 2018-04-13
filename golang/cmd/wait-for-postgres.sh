# https://docs.docker.com/compose/startup-order/
# wait-for-postgres.sh

set -e
set -x

echo $DATABASE_URL

until migrate -verbose -path example/db/migrations -database $DATABASE_URL up; do
  sleep 1
done

exec $*
