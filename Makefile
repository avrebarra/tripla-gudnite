# Minimal Makefile for Rails Development



.PHONY: start migrate create-migration generate-rswag test lint seed

start:
	bundle exec rails server

migrate:
	bundle exec rails db:migrate

generate-apidoc:
	bundle exec rake rswag:specs:swaggerize

test:
	bundle exec rspec

lint:
	bundle exec rubocop -A

seed:
	bundle exec rails db:seed
