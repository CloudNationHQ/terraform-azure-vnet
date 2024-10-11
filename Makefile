.PHONY: test docs fmt validate install-tools

export EXAMPLE

all: install-tools validate fmt docs

install-tools:
	@go install github.com/terraform-docs/terraform-docs@latest

test:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/$(EXAMPLE) ./deploy_test.go

docs:
	@echo "Generating documentation for root and modules..."
	@BASE_DIR=$$(pwd); \
	terraform-docs markdown . --output-file $$BASE_DIR/README.md --output-mode inject --hide modules; \
	for dir in $$BASE_DIR/modules/*; do \
		if [ -d "$$dir" ]; then \
			echo "Processing $$dir..."; \
			terraform-docs markdown $$dir --output-file $$dir/README.md --output-mode inject --hide modules || echo "Skipped: $$dir"; \
		fi \
	done

fmt:
	terraform fmt -recursive

validate:
	terraform init -backend=false
	terraform validate
	@echo "Cleaning up initialization files..."
	@rm -rf .terraform
	@rm -f terraform.tfstate
	@rm -f terraform.tfstate.backup
	@rm -f .terraform.lock.hcl
