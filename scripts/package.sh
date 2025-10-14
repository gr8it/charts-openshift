#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
OUTPUT_DIR="$(realpath "${SCRIPT_DIR}/../packaged_charts")"
INDEX_FILE="$(realpath "${SCRIPT_DIR}/../index.yaml")"
TEMP_DIR="$(mktemp -d)"
CHARTS_DIR="$(realpath "${SCRIPT_DIR}/../charts")"

# setup path variables
if [[ -n "${CHARTFOLDER:-}" ]]; then
  CHARTFOLDERS="${CHARTS_DIR}/${CHARTFOLDER}"
else
  CHARTFOLDERS=$(find "${CHARTS_DIR}" -mindepth 2 -maxdepth 2 -type f -name Chart.yaml -printf '%h\n' | sort)
fi

## CHARTFOLDERS=($(find "$CHARTS_DIR" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/Chart.yaml' \; -print))

echo -e "\033[0;36m~> Starting helm package for all chart folders ...\033[0m"
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR/packaged_charts"
echo -e "\033[0;33mTemp folder set to $TEMP_DIR\033[0m"

for folder in ${CHARTFOLDERS}; do
  chart_name=$(grep '^name:' "$folder/Chart.yaml" | awk '{print $2}')
  chart_version=$(grep '^version:' "$folder/Chart.yaml" | awk '{print $2}')
  chart_name_version="${chart_name}-${chart_version}"
  echo -n "${chart_name_version}: "
  whitespaces=$(echo "${chart_name_version}: " | sed "s/./ /g")
  if [ -f "$OUTPUT_DIR/${chart_name}-${chart_version}.tgz" ]; then
    echo -e "\033[0;33mskipped\033[0m - Chart package already exists"
  else

    # Lint the chart
    echo -n "lint "
    helm_args=""
    if [ -f "$folder/values.lint.yaml" ]; then
      helm_args="--values $folder/values.lint.yaml"
    fi
    if out=$(helm lint "$folder" --quiet ${helm_args} 2>&1); then
      echo -e "\033[0;32mOK\033[0m "
      if [ -n "$out" ]; then echo "$out"; fi
    else
      echo -e "\033[0;31mFAILED\033[0m "
      echo "$out"
      exit 1
    fi

    # Check dependencies versions
    origin_url=$(git config --get remote.origin.url)
    https_url=$(sed -E 's/^(git@|https:\/\/)?([^:\/]+)[:/](.*)(.git)$/https:\/\/\2\/\3/' <<< "$origin_url")
    # raw_url=$(echo "$https_url" | sed -E 's#https://github.com/(.*)#https://raw.githubusercontent.com/\1#')
    dep_count=$(yq e '.dependencies | length' "$folder/Chart.yaml")
    if [ "$dep_count" -gt 0 ]; then
      for dep_idx in $(seq 0 $((dep_count-1))); do
        dep_name=$(yq e ".dependencies[$dep_idx].name" "$folder/Chart.yaml")
        dep_repo=$(yq e ".dependencies[$dep_idx].repository" "$folder/Chart.yaml")
        dep_repo_replaced=$(sed -E 's/https:\/\/raw.githubusercontent.com\/(.*)\/refs\/heads\/.*/https:\/\/github.com\/\1/' <<< "${dep_repo}")
        dep_version=$(yq e ".dependencies[$dep_idx].version" "$folder/Chart.yaml")
        if [[ "${dep_repo_replaced}" == "${https_url}" ]]; then
          dep_chart_dir="$CHARTS_DIR/$dep_name"
          if [ -f "$dep_chart_dir/Chart.yaml" ]; then
            latest_version=$(yq e '.version' "$dep_chart_dir/Chart.yaml")
            if [ "$dep_version" != "$latest_version" ]; then
              echo -e "${whitespaces}\033[0;33mWARNING: $chart_name depends on $dep_name version $dep_version, but latest is $latest_version. Please update!\033[0m"
            fi
          fi
        fi
      done
    fi

    # Run unittests
    echo -n "${whitespaces}unittests "
    if [ -d "$folder/tests/" ]; then
      if out=$(helm unittest --strict "$folder"); then
        echo -e "\033[0;32mOK\033[0m "
      else
        echo -e "\033[0;31mFAILED\033[0m "
        echo "$out"
        echo -e "\033[33mUpdate unittests snapshot and continue? [n/Y]"
        echo -e "\033[33mUpdate only when \033[31mreally sure\033[33m, that updating snapshot won't break anything!\033[0m"
        read -r confirmation
        if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
          exit 1
        else
          helm unittest -u "$folder"
          if ! out=$(helm unittest --strict "$folder"); then
            echo -e "\033[0;31mSTILL FAILING\033[0m "
            exit 1
          fi
        fi
      fi
    else
      echo "NA"
    fi

    # Package the chart
    echo -n "${whitespaces}package "
    if out=$(helm package "$folder" --version "$chart_version" --destination "$TEMP_DIR/packaged_charts" 2>&1); then
      echo -e "\033[0;32mDONE\033[0m - chart package has been created"
      touch "$TEMP_DIR/.index"
    else
      echo -e "\033[0;31mFAILED - packaging chart ${chart_name_version} has failed.\033[0m"
      echo "$out"
      exit 1
    fi
  fi
done

if [ -f "$TEMP_DIR/.index" ] && out=$(helm repo index --merge "$INDEX_FILE" "$TEMP_DIR" 2>&1); then
  echo -e "\033[0;36m~> Updating index file and moving new packaged charts to $(realpath "$OUTPUT_DIR") ...\033[0m"
  mv -vf "$TEMP_DIR/packaged_charts/"*.tgz "$OUTPUT_DIR"/
  mv -vf "$TEMP_DIR/index.yaml" "$INDEX_FILE"
elif [ ! -f "$TEMP_DIR/.index" ]; then
  echo -e "\033[0;33mNo new helm packages found.\033[0m"
else
  echo -e "\033[0;31mGenerating index file has failed.\033[0m"
  echo "$out"
  exit 1
fi

rm -rf "$TEMP_DIR"
