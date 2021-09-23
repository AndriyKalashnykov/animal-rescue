.DEFAULT_GOAL := help

SHELL := /bin/bash
SDKMAN := $(HOME)/.sdkman/bin/sdkman-init.sh
CURRENT_USER_NAME := $(shell whoami)

JAVA_VER := 11.0.11.hs-adpt

SDKMAN_EXISTS := @printf "sdkman"
NODE_EXISTS := @printf "npm"

define my_echo
	@echo '$(1) $(2)'
endef

#help: @ List available tasks on this project
help:
	@clear
	@echo "Usage: make COMMAND"
	@echo
	@echo "Commands :"
	@echo
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-22s\033[0m - %s\n", $$1, $$2}'

deps-check:
	@. $(SDKMAN)
ifndef SDKMAN_VERSION
	@curl -s "https://get.sdkman.io?rcupdate=false" | bash
	@. $(SDKMAN)
	ifndef SDKMAN_VERSION
		SDKMAN_EXISTS := @echo "sdkman! not found" && exit 1
	endif
endif
	@. $(SDKMAN) && echo N | sdk install java $(JAVA_VER) && sdk use java $(JAVA_VER)

NODE_WHICH := $(shell which npm)
ifeq ($(strip $(NODE_WHICH)),)
	NODE_EXISTS := @echo "node not found" && exit 1
endif

# nvm current
# nvm alias default 14.17.6
# nvm use 14.17.6

#check: @ Check installed tools
check: deps-check

	@printf "\xE2\x9C\x94 "
	$(SDKMAN_EXISTS)
	@printf " "
	$(NODE_EXISTS)
	@printf "\n"

#build-backend: @ Build backend
build-backend: check
	@./gradlew :backend:build -x test

#test-backend: @ Test backend
test-backend: check
	@./gradlew :backend:test

#run-backend: @ Run backend
run-backend: check build-backend
	@./gradlew :backend:bootRun -x test --args='--spring.profiles.active=default'

#stop-app: @ Stop backend + frontend
stop-app: check
	@./scripts/local.sh stop

#build-backend-image: @ Build backend Docker image
build-backend-image: test-backend
#	@pack build andriykalashnykov/animal-rescue-backend:latest --builder=gcr.io/paketo-buildpacks/builder:base --path=./backend
	@./gradlew :backend:clean :backend:build -x test :backend:bootBuildImage

#run-backend-image: @ Run backend Docker image
run-backend-image: build-backend-image
	@docker run --rm --env BPL_DEBUG_ENABLED=false --publish 8080:8080 andriykalashnykov/animal-rescue-backend:latest

#build-frontend: @ Build frontend
build-frontend: check
	@./gradlew :frontend:assemble -x test

#build-frontend-image: @ Build frontend Docker image
build-frontend-image: build-frontend
#	@pack build andriykalashnykov/animal-rescue-frontend:latest --env BP_NODE_RUN_SCRIPTS=build --buildpack gcr.io/paketo-buildpacks/nodejs --env APP_ROOT=build --env BP_NGINX_VERSION=1.21.3 --env PORT=8080 --buildpack paketo-buildpacks/nginx --buildpack paketo-community/staticfile --env BP_NODE_RUN_SCRIPTS=build --env NODE_VERBOSE=true --env BP_NODE_VERSION=14.17.6 --builder=paketobuildpacks/builder:base --path=./frontend
	@docker build frontend -t andriykalashnykov/animal-rescue-frontend:latest

#start-app: @ Start frontend + backend
start-app: check build-backend-image build-frontend
	@./scripts/local.sh start --quiet

#run-e2e: @ Run e2e: frontend + backend
run-e2e: check build-backend build-frontend
	@./scripts/local.sh ci

#start-local-containers: @ Start local containers: frontend + backend
start-local-containers: check
	@cd ./docker-compose && docker-compose up

#stop-local-containers: @ Stop local containers: frontend + backend
stop-local-containers: check
	@cd ./docker-compose && docker-compose down

test: check
	$(call my_echo,John Doe,101)

# docker run --rm --interactive --tty --init --env PORT=8080 --entrypoint bash --publish 3000:8080 andriykalashnykov/animal-rescue-frontend:latest
# http://localhost:3000/rescue/

# wait-on tcp:8080 &&