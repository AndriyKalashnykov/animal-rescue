.DEFAULT_GOAL := help

SHELL := /bin/bash
SDKMAN := $(HOME)/.sdkman/bin/sdkman-init.sh
CURRENT_USER_NAME := $(shell whoami)

JAVA_VER := 11.0.11.hs-adpt

SDKMAN_EXISTS := @printf "sdkman"
NODE_EXISTS := @printf "npm"


#help: @ List available tasks on this project
help:
	@clear
	@echo "Usage: make COMMAND"
	@echo
	@echo "Commands :"
	@echo
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-26s\033[0m - %s\n", $$1, $$2}'

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

#check: @ Check installed tools
check: deps-check

	@printf "\xE2\x9C\x94 "
	$(SDKMAN_EXISTS)
	@printf " "
	@printf "\n"

#build-backend: @ Build backend
build-backend: check
	@./gradlew :backend:clean :backend:build -x test

#test-backend: @ Test backend
test-backend: check
	@./gradlew :backend:test

#run-backend: @ Run backend without TO
run-backend: check build-backend
	@./gradlew :backend:bootRun -x test --args='--spring.profiles.active=default'

#run-backend-to-sleuth: @ Run backend with TO (Sleuth)
run-backend-to-sleuth: check build-backend
	@./gradlew :backend:bootRun -x test -Pto-sleuth --args='--spring.profiles.active=to-sleuth'

#run-backend-to-opentracing: @ Run backend with TO (OpenTracing)
run-backend-to-opentracing: check build-backend
	@./gradlew :backend:bootRun -x test -Pto-opentracing --args='--spring.profiles.active=to-opentracing'

#build-frontend: @ Build frontend
build-frontend: check
	@./gradlew :frontend:assemble -x test

#run-frontend: @ Run frontend
run-frontend: check
	@cd frontend && npm start

#start-app: @ Start app (backend + frontend)
start-app: check build-backend build-frontend
	@./scripts/local.sh start --quiet

#stop-app: @ Stop app (backend + frontend)
stop-app: check
	@./scripts/local.sh stop

#run-e2e: @ Run end-to-end test (backend + frontend)
run-e2e: check build-backend build-frontend
	@./scripts/local.sh ci
