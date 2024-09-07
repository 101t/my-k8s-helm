
install_deps:
	sudo bash ./scripts/install_dependencies.sh

test_postgres:
	sudo bash ./scripts/test_postgresql.sh

test_redis:
	sudo bash ./scripts/test_redis.sh

run_helm:
	export POSTGRES_PASSWORD='postgres'
	export REDIS_PASSWORD='123456'
	helm install my-release helm/ \
	--set postgresql.global.postgresql.auth.password=${POSTGRES_PASSWORD} \
	--set redis.auth.password=${REDIS_PASSWORD}