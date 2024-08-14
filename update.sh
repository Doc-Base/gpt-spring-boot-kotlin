#!/bin/bash
set -e

echo "================================================================================"
echo "[SUBMODULES] Updating submodules..."
git submodule update --init
echo "[SUBMODULES] Updating submodules... Done."

echo "================================================================================"
echo "[GENERATION] Generating Custom GPT documentation..."
find ./.output -mindepth 1 ! -name 'README.md' -exec rm -Rf {} +
sleep 1 # Wait for the filesystem to catch up
declare -a documentation_subdirectories=("gradle" "hibernate-orm" "kotlin" "spring-boot" "spring-data-jpa")
for subdir in "${documentation_subdirectories[@]}"; do
  if [[ "$subdir" == "gradle" ]]; then
    search_path="./$subdir/platforms/documentation/docs/src/docs/userguide"

    find "${search_path}" -type f -name "*.adoc" | while read -r src_file; do
      dest_file="${src_file/.\//./.output/}" # Replace './' with './.output/' at the beginning
      dest_file="${dest_file/platforms\/documentation\/docs\/src\/docs\/userguide\//}" # Remove '/platforms/documentation/docs/src/docs/userguide/' part

      mkdir -p "$(dirname "$dest_file")"
      cp "$src_file" "$dest_file"
    done
  fi

  if [[ "$subdir" == "hibernate-orm" ]]; then
    search_path="./$subdir/documentation/src/main/asciidoc"

    find "${search_path}" -type f -name "*.adoc" | while read -r src_file; do
      dest_file="${src_file/.\//./.output/}" # Replace './' with './.output/' at the beginning
      dest_file="${dest_file/documentation\/src\/main\/asciidoc\//}" # Remove 'documentation/src/main/asciidoc/' part

      mkdir -p "$(dirname "$dest_file")"
      cp "$src_file" "$dest_file"
    done
  fi

  if [[ "$subdir" == "kotlin" ]]; then
    search_path="./$subdir/docs/topics"

    find "${search_path}" -type f -name "*.md" | while read -r src_file; do
      dest_file="${src_file/.\//./.output/}" # Replace './' with './.output/' at the beginning
      dest_file="${dest_file/docs\/topics\//}" # Remove 'docs/topics/' part

      mkdir -p "$(dirname "$dest_file")"
      cp "$src_file" "$dest_file"
    done
  fi

  if [[ "$subdir" == "spring-boot" ]]; then
    search_path="./$subdir/spring-boot-project/spring-boot-docs/src/docs/antora"

    find "${search_path}" -type f -name "*.adoc" | while read -r src_file; do
      dest_file="${src_file/.\//./.output/}" # Replace './' with './.output/' at the beginning
      dest_file="${dest_file/spring-boot-project\/spring-boot-docs\/src\/docs\/antora\//}" # Remove 'spring-boot-project/spring-boot-docs/src/docs/antora/' part

      mkdir -p "$(dirname "$dest_file")"
      cp "$src_file" "$dest_file"
    done
  fi

  if [[ "$subdir" == "spring-data-jpa" ]]; then
    search_path="./$subdir/src/main/antora/modules/ROOT"

    find "${search_path}" -type f -name "*.adoc" | while read -r src_file; do
      dest_file="${src_file/.\//./.output/}" # Replace './' with './.output/' at the beginning
      dest_file="${dest_file/src\/main\/antora\/modules\/ROOT\//}" # Remove 'src/main/antora/modules/ROOT/' part

      mkdir -p "$(dirname "$dest_file")"
      cp "$src_file" "$dest_file"
    done
  fi
done
echo "[GENERATION] Generating Custom GPT documentation... Done."

echo "================================================================================"
echo "[INDEXING] Updating Custom GPT documentation REAME..."
cat ./.output/README.md | sed '/## File List/q' >> ./.output/README.md.temp
mv ./.output/README.md.temp ./.output/README.md
sleep 1 # Wait for the filesystem to catch up
{
    echo ""
    find ./.output -type f \( -name "*.adoc" -o -name "*.md" \) | grep -v 'README.md' | while read -r src_file; do
        # Get the relative file path
        relative_path="${src_file/.\//}"
        # Format as markdown link
        echo "- [${relative_path}](${relative_path})"
    done
    echo ""
} >> ./.output/README.md
echo "[INDEXING] Updating Custom GPT documentation README... Done."

echo "================================================================================"
echo "[ARCHIVING] Generating Custom GPT Knowledge Base..."
rm -Rf ./*.tar.gz
version_tag=$(date "+%Y.%m.%d")
archive_name="custom_gpt_spring_boot_kotlin_knowledge_base-v${version_tag}.tar.gz"
pushd ./.output
tar -czf "${archive_name}" *
popd
mv "./.output/${archive_name}" "./${archive_name}"
echo "[ARCHIVING] Generating Custom GPT Knowledge Base... Done."

echo "================================================================================"
echo ""
echo "You can now upload this archive to your Custom GPT Assistant: ./${archive_name}."
