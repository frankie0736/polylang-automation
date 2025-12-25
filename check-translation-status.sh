#!/bin/bash

# Check translation status for all published posts
# Shows which posts are missing translations

echo "========================================="
echo "Translation Status Report"
echo "========================================="
echo ""

# Get all configured languages
LANGUAGES=$(wp term list language --field=slug --format=csv)
LANG_COUNT=$(echo "$LANGUAGES" | wc -w)

echo "Configured languages ($LANG_COUNT): $LANGUAGES"
echo ""

# Get all published posts
POST_IDS=$(wp post list --post_type=post --post_status=publish --field=ID --format=csv)

echo "Checking published posts..."
echo ""

INCOMPLETE_COUNT=0
COMPLETE_COUNT=0
NO_TRANSLATION_COUNT=0

for POST_ID in $POST_IDS; do
    # Get post language
    POST_LANG=$(wp post term list "$POST_ID" language --field=slug 2>/dev/null)

    # Get translation group
    TRANS_GROUP=$(wp post term list "$POST_ID" post_translations --field=description 2>/dev/null)

    # Get post title
    POST_TITLE=$(wp post get "$POST_ID" --field=post_title 2>/dev/null)

    if [ -z "$TRANS_GROUP" ]; then
        # No translation group = isolated post
        echo "❌ MISSING ALL: ID=$POST_ID | Lang=$POST_LANG | $POST_TITLE"
        NO_TRANSLATION_COUNT=$((NO_TRANSLATION_COUNT + 1))
    else
        # Count languages in translation group
        TRANS_COUNT=$(echo "$TRANS_GROUP" | grep -o 's:2:"[a-z][a-z]"' | wc -l)

        if [ "$TRANS_COUNT" -lt "$LANG_COUNT" ]; then
            # Parse which languages exist
            EXISTING_LANGS=$(echo "$TRANS_GROUP" | grep -oE 's:2:"[a-z]{2}"' | grep -oE '[a-z]{2}' | tr '\n' ',' | sed 's/,$//')
            echo "⚠️  INCOMPLETE: ID=$POST_ID | $TRANS_COUNT/$LANG_COUNT langs | Has: $EXISTING_LANGS | $POST_TITLE"
            INCOMPLETE_COUNT=$((INCOMPLETE_COUNT + 1))
        else
            COMPLETE_COUNT=$((COMPLETE_COUNT + 1))
        fi
    fi
done

echo ""
echo "========================================="
echo "Summary:"
echo "========================================="
echo "✅ Complete translations: $COMPLETE_COUNT"
echo "⚠️  Incomplete translations: $INCOMPLETE_COUNT"
echo "❌ No translations: $NO_TRANSLATION_COUNT"
echo "Total published posts: $(echo "$POST_IDS" | wc -w)"
