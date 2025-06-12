.PHONY: all install-tools validate fmt docs test test-parallel test-sequential

all: install-tools validate fmt docs

install-tools:
	go install github.com/terraform-docs/terraform-docs@latest

TEST_ARGS := $(if $(skip-destroy),-skip-destroy=$(skip-destroy)) \
             $(if $(exception),-exception=$(exception)) \
             $(if $(example),-example=$(example))

test:
	cd tests && go test -v -timeout 60m -run '^TestApplyNoError$$' -args $(TEST_ARGS) .

test-parallel:
	cd tests && go test -v -timeout 60m -run '^TestApplyAllParallel$$' -args $(TEST_ARGS) .

docs:
	@echo "Generating documentation for root and modules..."
	terraform-docs markdown document . --output-file README.md --output-mode inject --hide modules
	for dir in modules/*; do \
		if [ -d "$$dir" ]; then \
			echo "Processing $$dir..."; \
			(cd "$$dir" && terraform-docs markdown document . --output-file README.md --output-mode inject --hide modules) || echo "Skipped: $$dir"; \
		fi \
	done

fmt:
	terraform fmt -recursive

validate:
	terraform init -backend=false
	terraform validate
	@echo "Cleaning up initialization files..."
	rm -rf .terraform terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl
