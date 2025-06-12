.phony: all install-tools validate fmt docs test test-parallel test-sequential

all: install-tools validate fmt docs

install-tools:
	go install github.com/terraform-docs/terraform-docs@latest

test_args := $(if $(skip-destroy),-skip-destroy=$(skip-destroy)) \
             $(if $(exception),-exception=$(exception)) \
             $(if $(example),-example=$(example))

test:
	cd tests && go test -v -timeout 60m -run '^testapplynoerror$$' -args $(test_args) .

test-parallel:
	cd tests && go test -v -timeout 60m -run '^testapplyallparallel$$' -args $(test_args) .

docs:
	@echo "generating documentation for root and modules..."
	terraform-docs markdown document . --output-file README.md --output-mode inject --hide modules
	for dir in modules/*; do \
		if [ -d "$$dir" ]; then \
			echo "processing $$dir..."; \
			(cd "$$dir" && terraform-docs markdown document . --output-file README.md --output-mode inject --hide modules) || echo "skipped: $$dir"; \
		fi \
	done

fmt:
	terraform fmt -recursive

validate:
	terraform init -backend=false
	terraform validate
	@echo "cleaning up initialization files..."
	rm -rf .terraform terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl
