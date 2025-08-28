.DEFAULT_GOAL := help

SHELL := /bin/bash
SDKMAN := $(HOME)/.sdkman/bin/sdkman-init.sh
CURRENT_USER_NAME := $(shell whoami)

JAVA_VER  := 11.0.11.hs-adpt
MAVEN_VER := 3.9.1

SDKMAN_EXISTS := @printf "sdkman"
NODE_EXISTS := @printf "npm"


#help: @ List available tasks
help:
	@clear
	@echo "Usage: make COMMAND"
	@echo
	@echo "Commands :"
	@echo
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-26s\033[0m - %s\n", $$1, $$2}'

build-deps-check:
	@. $(SDKMAN)
ifndef SDKMAN_DIR
	@curl -s "https://get.sdkman.io?rcupdate=false" | bash
	@source $(SDKMAN)
	ifndef SDKMAN_DIR
		SDKMAN_EXISTS := @echo "SDKMAN_VERSION is undefined" && exit 1
	endif
endif

	@. $(SDKMAN) && echo N | sdk install java $(JAVA_VER) && sdk use java $(JAVA_VER)
	@. $(SDKMAN) && echo N | sdk install maven $(MAVEN_VER) && sdk use maven $(MAVEN_VER)

#check-env: @ Check environment variables and installed tools
check-env: build-deps-check

	@printf "\xE2\x9C\x94 "
	$(SDKMAN_EXISTS)
	@printf "\n"

#build-backend: @ Build backend
build-backend: check-env
	@./gradlew :backend:clean :backend:build -x test

#test-backend: @ Test backend
test-backend: check-env
	@./gradlew :backend:test

#run-backend: @ Run backend without TO
run-backend:  build-backend
	@./gradlew :backend:bootRun -x test --args='--spring.profiles.active=default'

#run-backend-to-sleuth: @ Run backend with TO (Sleuth)
run-backend-to-sleuth:  build-backend
	@./gradlew :backend:bootRun -x test -Pto-sleuth --args='--spring.profiles.active=to-sleuth'

#run-backend-to-opentracing: @ Run backend with TO (OpenTracing)
run-backend-to-opentracing:  build-backend
	@./gradlew :backend:bootRun -x test -Pto-opentracing --args='--spring.profiles.active=to-opentracing'

#build-frontend: @ Build frontend
build-frontend: 
	@./gradlew :frontend:assemble -x test

#run-frontend: @ Run frontend
run-frontend: 
	@cd frontend && npm start

#run-e2e: @ Run end-to-end tests (backend + frontend)
run-e2e: build-backend build-frontend
	@./scripts/local.sh ci

#start-app: @ Start app (backend + frontend)
start-app:  build-backend build-frontend
	@./scripts/local.sh start --quiet

#stop-app: @ Stop app (backend + frontend)
stop-app: 
	@./scripts/local.sh stop
