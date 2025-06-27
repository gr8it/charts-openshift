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
	@for folder in $(CHARTFOLDERS); do \
		echo "Chart lint in folder: $$folder "; \
		helm lint $$folder; \
	done

package:
	@mkdir -p $(OUTPUT_DIR)
	# Git pull so the version check is done against the latest and gratest version in the repo
	@ git pull; \
	if [ $$? -ne 0  ]; then \
		echo "Couldn't update repo! Exiting .."; \
		exit 1; \
	fi
	@for folder in $(CHARTFOLDERS); do \
			chart_name=$$(basename $${folder}); \
			chart_version=$$(grep '^version:' $${folder}/Chart.yaml | awk '{print $$2}'); \
			if [ -f $(OUTPUT_DIR)/$${chart_name}-$${chart_version}.tgz ]; then \
					echo -e "Chart package $${chart_name}-$${chart_version} already exists - \e[33mskipping\e[0m. Increase version in Chart.yaml and package again"; \
			else \
					echo "Packaging chart $${chart_name}-$${chart_version}"; \
					helm package $${folder} --version $${chart_version} --destination $(OUTPUT_DIR); \
			fi \
	done

index:
	echo "Charts index file ... "
	helm repo index $(CURDIR)/..

build: lint package index

publish:
	echo "Charts publish ... "
	helm repo add --force-update --username $${REPO_USERNAME} --password $${REPO_TOKEN} helm_charts_repo ${REPO_URL}
	@for name in $(CURDIR)/../*.tgz; do\
    	echo $${name}; \
		helm cm-push $${name} helm_charts_repo; \
	done

clean:
