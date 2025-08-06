SHELL := /bin/bash

ifeq ($(strip $(CHARTFOLDER)),)
  CHARTFOLDER := $(CURDIR)
  CHARTFOLDERS := $(wildcard $(CHARTFOLDER)/../charts/*/)
else
  CHARTFOLDERS := $(addprefix $(CURDIR)/../charts/, $(CHARTFOLDER))
endif

ROOT_DIR   := $(shell realpath $(CURDIR)/..)
CHARTS_DIR := $(shell realpath $(ROOT_DIR)/charts)
OUTPUT_DIR := $(shell realpath $(ROOT_DIR)/packaged_charts)
INDEX_FILE := $(shell realpath $(ROOT_DIR)/index.yaml)
INDEX_ROOT := $(shell dirname $(INDEX_FILE))

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
			echo -e "\033[0;31mPackaging chart $${chart_name}-$${chart_version} has failed.\033[0m"; \
			echo "$$out"; \
			exit 1; \
		fi \
	done
	@if test -f $(TEMP_DIR)/.index  &&  out=$$(helm repo index --merge $(INDEX_FILE) $(TEMP_DIR) 2>&1); then \
		echo -e "\033[0;36m~> Updating index file and moving new packaged charts to $$(realpath $(OUTPUT_DIR)) ...\033[0m"; \
		mv -vf $(TEMP_DIR)/packaged_charts/*.tgz $(OUTPUT_DIR)/; \
		mv -vf $(TEMP_DIR)/index.yaml $(INDEX_FILE); \
	elif (test ! -f $(TEMP_DIR)/.index); then \
		echo -e "\033[0;33mNo new helm packages found.\033[0m"; \
	else \
		echo -e "\033[0;31mGenerating index file has failed.\033[0m"; \
		echo "$$out"; \
		exit 1; \
	fi
	@rm -rf $(TEMP_DIR)

check-yq:
	@if (command -v yq >/dev/null 2>&1); then \
		version=$$(yq --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "0"); \
	else \
		echo -e "\033[0;31myq not found; please install it.\033[0m"; \
		exit 1; \
	fi; \
	if test "4" -ne "$${version%%.*}"; then \
		echo -e "\033[0;31myq version 4 is required; found version $${version}.\033[0m"; \
		exit 1; \
	fi

reset-index:
	@echo "Regenerating charts index file ... "
	@helm repo index $(CURDIR)/..

publish:
	@echo "Charts publish ... "
	@helm repo add --force-update --username $${REPO_USERNAME} --password $${REPO_TOKEN} helm_charts_repo ${REPO_URL}
	@for name in $(CURDIR)/../*.tgz; do\
		echo $${name}; \
		helm cm-push $${name} helm_charts_repo; \
	done

clean: check-yq
	@echo -e "\033[0;36m~> Cleanup of orphaned helm packages and index references ...\033[0m"
	$(eval CHARTS_LIST := $(shell yq eval '(.entries | keys)[]' $(INDEX_FILE)))
  # Cleanup all references and artefacts for charts that are no logner available
	@declare -a package_cleanup=(); \
	for chart_name in $(CHARTS_LIST); do \
		test -n "$$(ls -A $(CHARTS_DIR)/$${chart_name} 2>/dev/null)" && continue; \
		tgz_urls=$$(yq eval "(.entries.$${chart_name}[].urls)[]" $(INDEX_FILE) | grep -e '\.tgz$$'); \
		while IFS= read -r tgz_file; do \
			if test -f "$(INDEX_ROOT)/$${tgz_file:-notfound}"; then \
				package_cleanup+=("$$tgz_file"); \
			fi; \
		done <<<"$$tgz_urls"; \
	done; \
	if test $${#package_cleanup[@]} -gt 0; then \
		for package_url in $${package_cleanup[@]}; do \
			echo -e "Removing orphaned file \033[0;31m$(INDEX_ROOT)/$${package_url}\033[0m and updating index."; \
			git rm -f --quiet --ignore-unmatch "$(INDEX_ROOT)/$$package_url"; \
			rm -f "$(INDEX_ROOT)/$$package_url"; \
			yq eval "(.entries[].[] | select(.urls[] == \"$${package_url}\").urls) -= [\"$${package_url}\"]" -i $(INDEX_FILE); \
		done; \
	fi
  # Remove all chart packages that have no reference in index
	@for pkg_file in "$(OUTPUT_DIR)"/*.tgz; do \
		pkg_relative=$$(echo "$$pkg_file" | sed "s|^$(INDEX_ROOT)/||"); \
		if ! yq eval --exit-status ".entries.*[].urls | contains([\"$${pkg_relative:-notfound}\"])" $(INDEX_FILE) >/dev/null 2>&1; then \
			echo -e "Removing orphaned file \033[0;31m$(INDEX_ROOT)/$${pkg_relative}\033[0m not found in index."; \
			git rm -f --quiet --ignore-unmatch "$(INDEX_ROOT)/$$pkg_relative"; \
			rm -f "$(INDEX_ROOT)/$$pkg_relative"; \
		fi; \
	done
  # Cleanup index and remove orphaned references to packaged charts
	$(eval PKGURL_LIST := $(shell yq eval '.entries.*[].urls|.[]' $(INDEX_FILE)))
	@for package_url in $(PKGURL_LIST); do \
		if test ! -f "$(INDEX_ROOT)/$${package_url}"; then \
			echo -e "Removing orphaned url reference \033[0;31m$${package_url}\033[0m from index."; \
			yq eval "(.entries[].[] | select(.urls[] == \"$${package_url}\").urls) -= [\"$${package_url}\"]" -i $(INDEX_FILE); \
		fi; \
	done
  # Remove version references with empty urls from the index
	@if yq --exit-status eval '.entries[].[] | select(.urls[] == null)' $(INDEX_FILE) >/dev/null 2>&1; then \
		echo "Removing all unlinked version references from index."; \
		yq eval 'del(.entries[].[] | select(.urls[] == null))' -i $(INDEX_FILE) >/dev/null 2>&1; \
	fi
  # Remove empty helm chart references with no versions from the index
	@if yq --exit-status eval '.entries | to_entries[] | select(.value[] == null) | .key' $(INDEX_FILE) >/dev/null 2>&1; then \
		echo "Removing all empty chart references from index."; \
		yq eval 'del(.entries[] | select(length == 0))' -i $(INDEX_FILE); \
	fi
  # Update the 'generated' timestamp if index file has been modified in the last minute
	@if test -n "$$(find $(INDEX_FILE) -mmin -1)"; then \
		echo "Updating index timestamp."; \
		yq eval ".generated |= \"$$(date -u +'%Y-%m-%dT%H:%M:%SZ')\"" -i $(INDEX_FILE); \
	fi

build: gitpull lint package
