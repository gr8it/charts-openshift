SHELL := /bin/bash

ifeq ($(strip $(CHARTFOLDER)),)
	CHARTFOLDER := $(CURDIR)
	CHARTFOLDERS := $(wildcard $(CHARTFOLDER)/../charts/*/)
else
	CHARTFOLDERS := $(addprefix $(CURDIR)/../charts/, $(CHARTFOLDER))
endif

CHARTS_DIR := $(CURDIR)/../charts
OUTPUT_DIR := $(CURDIR)/../packaged_charts

debug:
	@echo "$${REPO_USERNAME}"
	@echo "$${REPO_TOKEN}"
	@echo ${REPO_URL}

lint:
	@echo -e "\033[0;36m~> Starting helm lint checks on all chart folders ...\033[0m"
	@for folder in $(CHARTFOLDERS); do \
		echo -n "$$(basename $${folder}): Lint check "; \
		if out=$$(helm lint $$folder --quiet 2>&1); then \
			echo -e "\033[0;32mOK\033[0m."; \
			if test -n "$$out"; then echo "$$out"; fi; \
		else \
			echo -e "\033[0;31mFAILED\033[0m."; \
			echo "$$out"; \
			exit 1; \
		fi; \
	done

gitpull:
	@echo -e "\033[0;36m~> Synchronizing with the latest Git repository state ...\033[0m"
	@if ! git pull; then \
		echo -e "\033[0;31mFailed to update git repo.\033[0m"; \
		exit 1; \
	fi

package:
	@echo -e "\033[0;36m~> Starting helm package for all chart folders ...\033[0m"
	@mkdir -p $(OUTPUT_DIR)
	$(eval TEMP_DIR := $(shell mktemp -d))
	@mkdir -p $(TEMP_DIR)/packaged_charts
	@echo -e "\033[0;33mTemp folder set to $(TEMP_DIR)\033[0m"
	@for folder in $(CHARTFOLDERS); do \
		chart_name=$$(basename $${folder}); \
		chart_version=$$(grep '^version:' $${folder}/Chart.yaml | awk '{print $$2}'); \
		if [ -f $(OUTPUT_DIR)/$${chart_name}-$${chart_version}.tgz ]; then \
			echo -e "$${chart_name}-$${chart_version}: \033[0;33mskipped\033[0m - Chart package already exists"; \
		elif out=$$(helm package $${folder} --version $${chart_version} --destination $(TEMP_DIR)/packaged_charts 2>&1); then \
			echo -e "$${chart_name}-$${chart_version}: \033[0;32mdone - Chart package has been created\033[0m"; \
			touch $(TEMP_DIR)/.index; \
		else \
			echo -e "\033[0;31mPackaging cahrt $${chart_name}-$${chart_version} has failed.\033[0m"; \
			echo "$$out"; \
			exit 1; \
		fi \
	done
	@if test -f $(TEMP_DIR)/.index  &&  out=$$(helm repo index --merge $(CURDIR)/../index.yaml $(TEMP_DIR) 2>&1); then \
		echo -e "\033[0;36m~> Updating index file and moving new packaged charts to $$(realpath $(OUTPUT_DIR)) ...\033[0m"; \
		mv -vf $(TEMP_DIR)/packaged_charts/*.tgz $(OUTPUT_DIR)/; \
		mv -vf $(TEMP_DIR)/index.yaml $(CURDIR)/../index.yaml; \
	elif (test ! -f $(TEMP_DIR)/.index); then \
		echo -e "\033[0;33mNo new helm packages found.\033[0m"; \
	else \
		echo -e "\033[0;31mGenerating index file has failed.\033[0m"; \
		echo "$$out"; \
		exit 1; \
	fi
	@rm -rf $(TEMP_DIR)

reindex:
	@echo "Regenerating charts index file ... "
	@helm repo index $(CURDIR)/..

build: gitpull lint package

publish:
	@echo "Charts publish ... "
	@helm repo add --force-update --username $${REPO_USERNAME} --password $${REPO_TOKEN} helm_charts_repo ${REPO_URL}
	@for name in $(CURDIR)/../*.tgz; do\
		echo $${name}; \
		helm cm-push $${name} helm_charts_repo; \
	done

clean:
