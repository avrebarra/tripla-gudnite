# Minimal Makefile for Rails Development

.PHONY: start migrate create-migration generate-rswag test

start:
	bundle exec rails server

migrate:
	bundle exec rails db:migrate

generate-rswag:
	bundle exec rails generate rswag:install

test:
	bundle exec rails test
