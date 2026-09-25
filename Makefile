up:
	docker compose up -d
down:
	docker compose down
reset:
	docker compose run --rm reset
check-infra:
	docker compose run --rm ruby ruby /work/scripts/infra_check.rb