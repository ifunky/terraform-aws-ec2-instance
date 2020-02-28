.SHELL := /usr/bin/bash

METADATA_DOCS_FILE := "docs/metadata.md"
TARGETS_DOCS_FILE  := "docs/targets.md"

export README_INCLUDES ?= $(file://$(shell pwd)/?type=text/plain)

define polydev
	@docker run -it \
		--env AWS_DEFAULT_REGION="eu-west-1" \
		--user "$$(id -u):$$(id -g)" \
		-v "$$PWD:/data" \
		ifunky/polydev:latest $1
endef

#####################################################################
# Private targets designed to be run within the PolyDev shell	
#####################################################################
init: 
	@terraform init -input=false

validate: init
	@echo Running validation on Terraform code....
	@terraform validate
	@echo Running lint checks on Terraform code....
	@tflint

createdocs/targets: # Create list of make targets in Markdown format
	@echo Auto creating README.md....
	@rm -rf $(TARGETS_DOCS_FILE)
	@echo "## Makefile Targets" >> $(TARGETS_DOCS_FILE)
	@echo -e "The following targets are available: \n" >> $(TARGETS_DOCS_FILE)
	@echo '```' >> $(TARGETS_DOCS_FILE)
	@grep -E '^[a-zA-Z_-_\/]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\%-30s\ %s\n", $$1, $$2}' >> $(TARGETS_DOCS_FILE)
	@echo '```' >> $(TARGETS_DOCS_FILE)

createdocs: createdocs/targets # Auto create README.md documentaion
	@terraform-config-inspect > $(METADATA_DOCS_FILE)
	@sed -i -e '1,2d' $(METADATA_DOCS_FILE)   				# Remove first line as not needed
	@sed -i '1i# Module Specifics' $(METADATA_DOCS_FILE)	# Add title to first line
	@gomplate --file ./docs/README.md.template \
	--out README.md

#####################################################################
# Public targets designed to be run directly from the command line
#####################################################################
help:
	@grep -E '^[a-zA-Z_-_\/]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

createdocs/help: ## Create documentation help
	@echo "--------------------------------------------------------------------------"
	@echo "Createdocs - How to create/update README.md"
	@echo "--------------------------------------------------------------------------"
	@echo "- Update README.yaml with relevant documentation"
	@echo "- Run make polydev/createdocs directly from your shell"
	@echo "- Alternativly from within the PolyDev shell run make createdocs"
	@echo "- Your README.md has been created :-)"


polydev: ## Run PolyDev interactive shell to start developing with all the tools or run AWS CLI commands :-)
	$(call polydev)

polydev/help: ## Help on using PolyDev locally
	@echo "--------------------------------------------------------------------------"
	@echo "PolyDev Help - Running Helper Targets"
	@echo "--------------------------------------------------------------------------"
	@echo "Get yourself setup on PolyDev: https://git.fincore.com/cmp/polydev" 
	@echo 
	@echo " - Run make targets polydev/{target} directly from your shell "
	@echo " - To run the PolyDev interactive shell run make polydev"
	@echo "--------------------------------------------------------------------------"

polydev/createdocs: ## Run PolyDev createdocs directly from your shell
	$(call polydev,make createdocs)

polydev/init: ## Initialise the project
	$(call polydev,make init)

polydev/validate: ## Validate the code
	$(call polydev,make validate)