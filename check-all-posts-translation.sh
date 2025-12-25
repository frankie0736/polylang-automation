#!/bin/bash

# Generate CSV report for all posts translation status
# Only checks post_type=post (not pages or other types)

OUTPUT_FILE="posts-translation-report.csv"

echo "Generating translation report for all posts..."

# Get all configured languages
ALL_LANGS=$(wp term list language --field=slug --format=csv | tr '\n' ',' | sed 's/,$//')
LANG_COUNT=$(wp term list language --format=count)

echo "Configured languages ($LANG_COUNT): $ALL_LANGS"
echo ""

# CSV Header
echo "ID,Title,Status,Language,Translation_Group,Has_Langs,Missing_Langs,Translation_Status" > "$OUTPUT_FILE"

# Get ALL posts (publish + draft + any status)
POST_IDS=$(wp post list --post_type=post --post_status=any --field=ID --format=csv)

TOTAL_COUNT=0
for POST_ID in $POST_IDS; do
    TOTAL_COUNT=$((TOTAL_COUNT + 1))

    # Get post info
    POST_TITLE=$(wp post get "$POST_ID" --field=post_title 2>/dev/null | sed 's/"/""/g')
    POST_STATUS=$(wp post get "$POST_ID" --field=post_status 2>/dev/null)
    POST_LANG=$(wp post term list "$POST_ID" language --field=slug 2>/dev/null)

    # Get translation group
    TRANS_GROUP=$(wp post term list "$POST_ID" post_translations --field=description 2>/dev/null)

    if [ -z "$TRANS_GROUP" ]; then
        # No translation group
        STATUS="NO_TRANSLATIONS"
        HAS_LANGS="$POST_LANG"
        MISSING_LANGS=$(echo "$ALL_LANGS" | sed "s/$POST_LANG,//g" | sed "s/,$POST_LANG//g" | sed "s/$POST_LANG//g")
        TRANS_COUNT="0"
    else
        # Parse translation group to get languages
        HAS_LANGS=$(echo "$TRANS_GROUP" | grep -oE 's:2:"[a-z]{2}"' | grep -oE '[a-z]{2}' | tr '\n' ',' | sed 's/,$//')
        TRANS_COUNT=$(echo "$HAS_LANGS" | tr ',' '\n' | grep -c '^')

        if [ "$TRANS_COUNT" -eq "$LANG_COUNT" ]; then
            STATUS="COMPLETE"
            MISSING_LANGS=""
        else
            STATUS="INCOMPLETE"
            # Calculate missing languages
            MISSING_LANGS=""
            for lang in $(echo "$ALL_LANGS" | tr ',' '\n'); do
                if ! echo "$HAS_LANGS" | grep -q "$lang"; then
                    if [ -z "$MISSING_LANGS" ]; then
                        MISSING_LANGS="$lang"
                    else
                        MISSING_LANGS="$MISSING_LANGS,$lang"
                    fi
                fi
            done
        fi
    fi

    # Escape title for CSV
    TITLE_ESCAPED="\"$POST_TITLE\""

    # Write to CSV
    echo "$POST_ID,$TITLE_ESCAPED,$POST_STATUS,$POST_LANG,\"$HAS_LANGS\",\"$MISSING_LANGS\",$STATUS" >> "$OUTPUT_FILE"

    # Progress indicator
    if [ $((TOTAL_COUNT % 10)) -eq 0 ]; then
        echo "Processed $TOTAL_COUNT posts..."
    fi
done

echo ""
echo "========================================="
echo "Report generated: $OUTPUT_FILE"
echo "Total posts processed: $TOTAL_COUNT"
echo "========================================="
echo ""

# Generate summary
COMPLETE=$(grep ",COMPLETE$" "$OUTPUT_FILE" | wc -l)
INCOMPLETE=$(grep ",INCOMPLETE$" "$OUTPUT_FILE" | wc -l)
NO_TRANS=$(grep ",NO_TRANSLATIONS$" "$OUTPUT_FILE" | wc -l)

echo "Summary:"
echo "  ✅ Complete translations: $COMPLETE"
echo "  ⚠️  Incomplete translations: $INCOMPLETE"
echo "  ❌ No translations: $NO_TRANS"
echo ""
echo "View report: cat $OUTPUT_FILE"
