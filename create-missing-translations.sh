#!/bin/bash

################################################################################
# Polylang Missing Translations Creator
#
# Description: Given a post ID, automatically detects its language and creates
#              missing translation versions for all other configured languages
#
# Usage: bash create-missing-translations.sh <post_id>
# Example: bash create-missing-translations.sh 100
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

################################################################################
# Functions
################################################################################

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
  echo -e "${CYAN}[STEP]${NC} $1"
}

# Get the first available author
get_author_id() {
  local author_id=$(wp user list --format=csv --fields=ID 2>/dev/null | tail -n +2 | head -1)
  if [ -z "$author_id" ]; then
    log_error "No users found in WordPress"
    exit 1
  fi
  echo "$author_id"
}

# Get all configured languages in Polylang
get_all_languages() {
  wp term list language --format=json --fields=slug 2>/dev/null | grep -o '"slug":"[^"]*"' | cut -d'"' -f4
}

# Get language of a post
get_post_language() {
  local post_id=$1
  local lang=$(wp post term list "$post_id" language --format=csv --fields=slug 2>/dev/null | tail -1)

  if [ -z "$lang" ] || [ "$lang" = "slug" ]; then
    echo ""
  else
    echo "$lang"
  fi
}

# Get translation group slug for a post
get_translation_group() {
  local post_id=$1
  local trans_group=$(wp post term list "$post_id" post_translations --format=csv --fields=slug 2>/dev/null | tail -1)

  if [ -z "$trans_group" ] || [ "$trans_group" = "slug" ]; then
    echo ""
  else
    echo "$trans_group"
  fi
}

# Parse existing translations from description (PHP serialized array)
get_existing_translations() {
  local trans_group=$1

  # Get the description field which contains serialized PHP array
  local desc=$(wp term list post_translations --format=csv --fields=slug,description 2>/dev/null | grep "^$trans_group," | cut -d',' -f2-)

  if [ -z "$desc" ]; then
    echo ""
    return
  fi

  # Remove CSV quotes if present
  desc=$(echo "$desc" | sed 's/^"//; s/"$//' | sed 's/""/"/g')

  # Extract language codes from serialized array
  # Format: a:3:{s:2:"en";i:66;s:2:"zh";i:67;s:2:"es";i:68;}
  echo "$desc" | grep -o 's:2:"[^"]*"' | cut -d'"' -f2
}

# Get existing translation post ID for a language
get_translation_post_id() {
  local trans_group=$1
  local lang=$2

  local desc=$(wp term list post_translations --format=csv --fields=slug,description 2>/dev/null | grep "^$trans_group," | cut -d',' -f2-)

  if [ -z "$desc" ]; then
    echo "0"
    return
  fi

  # Remove CSV quotes if present
  desc=$(echo "$desc" | sed 's/^"//; s/"$//' | sed 's/""/"/g')

  # Extract post ID for specific language
  # Look for pattern like: s:2:"en";i:66;
  local post_id=$(echo "$desc" | grep -o "s:2:\"$lang\";i:[0-9]*" | grep -o 'i:[0-9]*' | cut -d':' -f2)

  if [ -z "$post_id" ]; then
    echo "0"
  else
    echo "$post_id"
  fi
}

# Convert title to slug
title_to_slug() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//'
}

################################################################################
# TRANSLATION LAYER
#
# This is where you can integrate AI translation services (OpenAI, Claude, etc.)
# Current implementation: Placeholder that adds language markers
# Production implementation: Replace with actual API calls
################################################################################

# Translate title from source language to target language
#
# PLACEHOLDER IMPLEMENTATION:
#   - Appends language name to original title
#
# PRODUCTION IMPLEMENTATION (replace this function):
#   translate_title() {
#     local source_lang=$1
#     local target_lang=$2
#     local source_title=$3
#
#     # Call translation API (OpenAI/Claude/Google Translate)
#     # Example with OpenAI:
#     # curl https://api.openai.com/v1/chat/completions \
#     #   -H "Content-Type: application/json" \
#     #   -H "Authorization: Bearer $OPENAI_API_KEY" \
#     #   -d "{
#     #     \"model\": \"gpt-4\",
#     #     \"messages\": [{
#     #       \"role\": \"user\",
#     #       \"content\": \"Translate this title from $source_lang to $target_lang: $source_title\"
#     #     }]
#     #   }" | jq -r '.choices[0].message.content'
#   }
translate_title() {
  local source_lang=$1
  local target_lang=$2
  local source_title=$3

  # Current placeholder: Add language marker
  case "$target_lang" in
    "zh") echo "${source_title} - 中文版" ;;
    "es") echo "${source_title} - Español" ;;
    "fr") echo "${source_title} - Français" ;;
    "de") echo "${source_title} - Deutsch" ;;
    "ja") echo "${source_title} - 日本語" ;;
    "pt") echo "${source_title} - Português" ;;
    "ru") echo "${source_title} - Русский" ;;
    "ar") echo "${source_title} - العربية" ;;
    "ko") echo "${source_title} - 한국어" ;;
    "en") echo "$source_title" ;;
    *) echo "${source_title} - [${target_lang}]" ;;
  esac
}

# Translate content from source language to target language
#
# PLACEHOLDER IMPLEMENTATION:
#   - Adds translation marker to original content
#
# PRODUCTION IMPLEMENTATION (replace this function):
#   translate_content() {
#     local source_lang=$1
#     local target_lang=$2
#     local source_content=$3
#
#     # Call translation API with proper content handling
#     # Example with Claude API:
#     # curl https://api.anthropic.com/v1/messages \
#     #   -H "x-api-key: $ANTHROPIC_API_KEY" \
#     #   -H "content-type: application/json" \
#     #   -d "{
#     #     \"model\": \"claude-3-5-sonnet-20241022\",
#     #     \"max_tokens\": 4096,
#     #     \"messages\": [{
#     #       \"role\": \"user\",
#     #       \"content\": \"Translate from $source_lang to $target_lang:\n\n$source_content\"
#     #     }]
#     #   }" | jq -r '.content[0].text'
#   }
translate_content() {
  local source_lang=$1
  local target_lang=$2
  local source_content=$3

  # Current placeholder: Add translation marker
  local marker
  case "$target_lang" in
    "zh") marker="[已翻译为中文]" ;;
    "es") marker="[Traducido al español]" ;;
    "fr") marker="[Traduit en français]" ;;
    "de") marker="[Ins Deutsche übersetzt]" ;;
    "ja") marker="[日本語に翻訳済み]" ;;
    "pt") marker="[Traduzido para português]" ;;
    "ru") marker="[Переведено на русский]" ;;
    "ar") marker="[مترجم إلى العربية]" ;;
    "ko") marker="[한국어로 번역됨]" ;;
    "en") marker="" ;;
    *) marker="[Translated to ${target_lang}]" ;;
  esac

  if [ -n "$marker" ]; then
    echo "$marker $source_content"
  else
    echo "$source_content"
  fi
}

################################################################################
# End of Translation Layer
################################################################################

# Create a post
create_post() {
  local title="$1"
  local slug="$2"
  local content="$3"
  local author_id="$4"

  local post_id=$(wp post create \
    --post_title="$title" \
    --post_name="$slug" \
    --post_content="$content" \
    --post_status=publish \
    --post_author="$author_id" \
    --porcelain 2>&1)

  if [[ "$post_id" =~ ^[0-9]+$ ]]; then
    echo "$post_id"
  else
    log_error "Failed to create post: $title"
    echo "0"
  fi
}

# Build serialized PHP array for translation mapping
# Input: space-separated list of "lang:postid" pairs
build_translation_array() {
  local pairs="$1"
  local count=$(echo "$pairs" | wc -w | tr -d ' ')

  local result="a:${count}:{"

  for pair in $pairs; do
    local lang=$(echo "$pair" | cut -d':' -f1)
    local post_id=$(echo "$pair" | cut -d':' -f2)
    result="${result}s:2:\"${lang}\";i:${post_id};"
  done

  result="${result}}"
  echo "$result"
}

# Helper: Get post ID from translation pairs by language
get_post_from_pairs() {
  local pairs="$1"
  local target_lang="$2"

  for pair in $pairs; do
    local lang=$(echo "$pair" | cut -d':' -f1)
    local post_id=$(echo "$pair" | cut -d':' -f2)
    if [ "$lang" = "$target_lang" ]; then
      echo "$post_id"
      return
    fi
  done
  echo ""
}

# Helper: Check if language exists in pairs
has_lang_in_pairs() {
  local pairs="$1"
  local target_lang="$2"

  for pair in $pairs; do
    local lang=$(echo "$pair" | cut -d':' -f1)
    if [ "$lang" = "$target_lang" ]; then
      return 0
    fi
  done
  return 1
}

################################################################################
# Main Script
################################################################################

echo ""
echo "=========================================="
echo "  Missing Translations Creator"
echo "=========================================="
echo ""

# Check arguments
if [ $# -ne 1 ]; then
  log_error "Usage: bash create-missing-translations.sh <post_id>"
  exit 1
fi

SOURCE_POST_ID=$1

# Validate post ID
if ! [[ "$SOURCE_POST_ID" =~ ^[0-9]+$ ]]; then
  log_error "Invalid post ID. Must be a number."
  exit 1
fi

# Check if post exists
if ! wp post get "$SOURCE_POST_ID" > /dev/null 2>&1; then
  log_error "Post ID $SOURCE_POST_ID does not exist."
  exit 1
fi

log_info "Source Post ID: $SOURCE_POST_ID"
echo ""

# Step 1: Get source post details
log_step "Step 1: Analyzing source post..."
SOURCE_TITLE=$(wp post get "$SOURCE_POST_ID" --field=post_title 2>/dev/null)
SOURCE_SLUG=$(wp post get "$SOURCE_POST_ID" --field=post_name 2>/dev/null)
SOURCE_CONTENT=$(wp post get "$SOURCE_POST_ID" --field=post_content 2>/dev/null)
SOURCE_LANG=$(get_post_language "$SOURCE_POST_ID")

if [ -z "$SOURCE_LANG" ]; then
  log_error "Source post has no language assigned. Please assign a language first."
  exit 1
fi

log_success "Post Title: $SOURCE_TITLE"
log_success "Post Slug: $SOURCE_SLUG"
log_success "Post Language: $SOURCE_LANG"
log_info "Content length: $(echo "$SOURCE_CONTENT" | wc -c | tr -d ' ') characters"
echo ""

# Step 2: Get all configured languages
log_step "Step 2: Detecting configured languages..."
ALL_LANGUAGES=($(get_all_languages))

if [ ${#ALL_LANGUAGES[@]} -eq 0 ]; then
  log_error "No languages configured in Polylang."
  exit 1
fi

log_success "Found ${#ALL_LANGUAGES[@]} configured languages: ${ALL_LANGUAGES[*]}"
echo ""

# Step 3: Check existing translation group
log_step "Step 3: Checking existing translation group..."
TRANS_GROUP=$(get_translation_group "$SOURCE_POST_ID")

# Translation pairs: space-separated "lang:postid" format
TRANSLATION_PAIRS=""

if [ -n "$TRANS_GROUP" ]; then
  log_success "Found existing translation group: $TRANS_GROUP"

  # Get existing translations
  EXISTING_LANGS=($(get_existing_translations "$TRANS_GROUP"))
  log_info "Existing translations: ${EXISTING_LANGS[*]}"

  # Build translation pairs from existing
  for lang in "${EXISTING_LANGS[@]}"; do
    post_id=$(get_translation_post_id "$TRANS_GROUP" "$lang")
    TRANSLATION_PAIRS="$TRANSLATION_PAIRS $lang:$post_id"
  done
else
  log_warning "No translation group found. Will create new one."
  TRANSLATION_PAIRS="$SOURCE_LANG:$SOURCE_POST_ID"
fi
echo ""

# Step 4: Determine missing languages
log_step "Step 4: Determining missing translations..."
MISSING_LANGUAGES=()

for lang in "${ALL_LANGUAGES[@]}"; do
  if ! has_lang_in_pairs "$TRANSLATION_PAIRS" "$lang"; then
    MISSING_LANGUAGES+=("$lang")
  fi
done

if [ ${#MISSING_LANGUAGES[@]} -eq 0 ]; then
  log_success "All language versions already exist! Nothing to do."
  echo ""
  log_info "Existing translations:"
  for pair in $TRANSLATION_PAIRS; do
    lang=$(echo "$pair" | cut -d':' -f1)
    post_id=$(echo "$pair" | cut -d':' -f2)
    post_url=$(wp post url "$post_id" 2>/dev/null)
    echo "  [$lang] Post ID $post_id - $post_url"
  done
  echo ""
  exit 0
fi

log_warning "Missing ${#MISSING_LANGUAGES[@]} language versions: ${MISSING_LANGUAGES[*]}"
echo ""

# Step 5: Get author
log_step "Step 5: Getting author information..."
AUTHOR_ID=$(get_author_id)
log_success "Author ID: $AUTHOR_ID"
echo ""

# Step 6: Create missing translations
log_step "Step 6: Creating missing translations..."
echo ""

CREATED_COUNT=0

for lang in "${MISSING_LANGUAGES[@]}"; do
  log_info "Creating [$lang] version..."

  # Generate slug
  if [ "$lang" = "$SOURCE_LANG" ]; then
    new_slug="$SOURCE_SLUG"
  else
    new_slug="${SOURCE_SLUG}-${lang}"
  fi

  # ========================================
  # TRANSLATION HAPPENS HERE
  # ========================================
  log_info "  Translating from [$SOURCE_LANG] to [$lang]..."

  # Translate title using translation layer
  new_title=$(translate_title "$SOURCE_LANG" "$lang" "$SOURCE_TITLE")

  # Translate content using translation layer
  new_content=$(translate_content "$SOURCE_LANG" "$lang" "$SOURCE_CONTENT")

  log_info "  Title: $new_title"
  # ========================================

  # Create post
  new_post_id=$(create_post "$new_title" "$new_slug" "$new_content" "$AUTHOR_ID")

  if [ "$new_post_id" -eq 0 ]; then
    log_error "Failed to create [$lang] version. Skipping."
    continue
  fi

  log_success "Created post ID $new_post_id"

  # Assign language
  wp post term set "$new_post_id" language "$lang" > /dev/null 2>&1
  log_success "Assigned language: $lang"

  # Add to translation pairs
  TRANSLATION_PAIRS="$TRANSLATION_PAIRS $lang:$new_post_id"

  CREATED_COUNT=$((CREATED_COUNT + 1))
  echo ""
done

log_success "Created $CREATED_COUNT new translation(s)"
echo ""

# Step 7: Update or create translation group
log_step "Step 7: Updating translation group..."

# Build serialized array
SERIALIZED_MAP=$(build_translation_array "$TRANSLATION_PAIRS")

if [ -n "$TRANS_GROUP" ]; then
  # Update existing group
  log_info "Updating existing translation group: $TRANS_GROUP"
  wp term update post_translations "$TRANS_GROUP" --description="$SERIALIZED_MAP" > /dev/null 2>&1
else
  # Create new group
  TRANS_GROUP="pll_$(openssl rand -hex 6)"
  log_info "Creating new translation group: $TRANS_GROUP"
  wp term create post_translations "$TRANS_GROUP" \
    --slug="$TRANS_GROUP" \
    --description="$SERIALIZED_MAP" > /dev/null 2>&1
fi

# Assign all posts to translation group
for pair in $TRANSLATION_PAIRS; do
  lang=$(echo "$pair" | cut -d':' -f1)
  post_id=$(echo "$pair" | cut -d':' -f2)
  wp post term set "$post_id" post_translations "$TRANS_GROUP" > /dev/null 2>&1
done

log_success "Translation group updated: $TRANS_GROUP"
echo ""

# Step 8: Flush rewrite rules
log_step "Step 8: Flushing rewrite rules..."
wp rewrite flush > /dev/null 2>&1
log_success "Rewrite rules flushed"
echo ""

# Summary
echo "=========================================="
echo "  Summary"
echo "=========================================="
echo ""

# Count total languages
TOTAL_LANGS=$(echo "$TRANSLATION_PAIRS" | wc -w | tr -d ' ')

log_success "Translation group: $TRANS_GROUP"
log_success "Total languages: $TOTAL_LANGS"
log_success "Created new: $CREATED_COUNT"
echo ""

log_info "All translations:"
for pair in $(echo "$TRANSLATION_PAIRS" | tr ' ' '\n' | sort); do
  lang=$(echo "$pair" | cut -d':' -f1)
  post_id=$(echo "$pair" | cut -d':' -f2)
  post_title=$(wp post get "$post_id" --field=post_title 2>/dev/null)
  post_url=$(wp post url "$post_id" 2>/dev/null)
  echo "  [$lang] ID $post_id - $post_title"
  echo "       → $post_url"
done
echo ""

log_success "All done! 🎉"
echo ""
