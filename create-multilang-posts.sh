#!/bin/bash

################################################################################
# Polylang Multi-language Post Creator
#
# Description: Automatically creates WordPress posts in EN/ZH/ES with Polylang
#              translation groups
#
# Usage: bash create-multilang-posts.sh [number_of_posts]
# Example: bash create-multilang-posts.sh 3
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEFAULT_POST_COUNT=1
POST_COUNT=${1:-$DEFAULT_POST_COUNT}

# Featured image IDs (will cycle through these)
FEATURED_IMAGES=(39 37 35 26 27 28)

# Article templates (title and content placeholders)
declare -a ARTICLE_TEMPLATES=(
  "Blockchain Technology in Finance|Blockchain technology is revolutionizing the financial sector with decentralized solutions, smart contracts, and transparent transaction systems. This innovation enables faster cross-border payments and reduces intermediary costs."
  "Cybersecurity Best Practices|In today's digital age, cybersecurity is more critical than ever. Organizations must implement multi-layered security approaches, regular security audits, and employee training to protect against evolving cyber threats."
  "Remote Work Revolution|The shift to remote work has transformed how businesses operate globally. Cloud collaboration tools, flexible schedules, and digital communication platforms are enabling productivity while maintaining work-life balance."
  "Sustainable Energy Solutions|Renewable energy sources like solar and wind power are becoming increasingly viable alternatives to fossil fuels. Investment in clean energy infrastructure is crucial for combating climate change."
  "E-commerce Trends 2025|Online shopping continues to evolve with AI-powered recommendations, augmented reality try-ons, and same-day delivery options. Mobile commerce is driving the future of retail."
  "Digital Marketing Strategies|Modern marketing leverages data analytics, social media engagement, and personalized content to reach target audiences. Understanding customer behavior is key to successful campaigns."
  "Quantum Computing Advances|Quantum computing promises to solve complex problems that are currently intractable for classical computers. Applications range from drug discovery to cryptography."
  "5G Network Technology|Fifth-generation wireless technology delivers faster speeds, lower latency, and supports the growing Internet of Things ecosystem. This enables smart cities and autonomous vehicles."
  "Biotechnology Innovations|Advances in gene editing, personalized medicine, and synthetic biology are transforming healthcare. CRISPR technology opens new possibilities for treating genetic diseases."
  "Space Exploration Updates|Private companies are joining government agencies in the new space race. Mars colonization, lunar bases, and space tourism are becoming realistic goals."
)

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

# Get the first available author
get_author_id() {
  local author_id=$(wp user list --format=csv --fields=ID | tail -n +2 | head -1)
  if [ -z "$author_id" ]; then
    log_error "No users found in WordPress"
    exit 1
  fi
  echo "$author_id"
}

# Convert title to slug
title_to_slug() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//'
}

# Get Chinese translation (placeholder)
get_zh_translation() {
  local en_title="$1"
  local en_content="$2"

  # Simple placeholder translations
  case "$en_title" in
    *"Blockchain"*) echo "区块链技术在金融领域的应用|区块链技术正在通过去中心化解决方案、智能合约和透明交易系统革新金融行业。这项创新实现了更快的跨境支付并降低了中介成本。" ;;
    *"Cybersecurity"*) echo "网络安全最佳实践|在当今数字时代，网络安全比以往任何时候都更为重要。组织必须实施多层安全方法、定期安全审计和员工培训，以防范不断演变的网络威胁。" ;;
    *"Remote Work"*) echo "远程工作革命|向远程工作的转变已经改变了全球企业的运营方式。云协作工具、灵活的时间表和数字通信平台在保持工作生活平衡的同时提高了生产力。" ;;
    *"Sustainable Energy"*) echo "可持续能源解决方案|太阳能和风能等可再生能源正成为化石燃料的可行替代品。投资清洁能源基础设施对应对气候变化至关重要。" ;;
    *"E-commerce"*) echo "2025年电子商务趋势|在线购物持续发展，包括AI驱动的推荐、增强现实试穿和当日送达选项。移动商务正在推动零售业的未来。" ;;
    *"Digital Marketing"*) echo "数字营销策略|现代营销利用数据分析、社交媒体互动和个性化内容来触达目标受众。了解客户行为是成功营销活动的关键。" ;;
    *"Quantum Computing"*) echo "量子计算进展|量子计算有望解决经典计算机目前无法处理的复杂问题。应用范围从药物发现到密码学。" ;;
    *"5G Network"*) echo "5G网络技术|第五代无线技术提供更快的速度、更低的延迟，并支持不断增长的物联网生态系统。这使智慧城市和自动驾驶汽车成为可能。" ;;
    *"Biotechnology"*) echo "生物技术创新|基因编辑、个性化医疗和合成生物学的进步正在改变医疗保健。CRISPR技术为治疗遗传疾病开辟了新的可能性。" ;;
    *"Space Exploration"*) echo "太空探索最新动态|私营公司正在加入政府机构参与新的太空竞赛。火星殖民、月球基地和太空旅游正成为现实目标。" ;;
    *) echo "占位符标题 - 中文|这是一段中文占位符内容。用于测试Polylang多语言功能的文章内容。" ;;
  esac
}

# Get Spanish translation (placeholder)
get_es_translation() {
  local en_title="$1"
  local en_content="$2"

  # Simple placeholder translations
  case "$en_title" in
    *"Blockchain"*) echo "Tecnología Blockchain en Finanzas|La tecnología blockchain está revolucionando el sector financiero con soluciones descentralizadas, contratos inteligentes y sistemas de transacciones transparentes. Esta innovación permite pagos transfronterizos más rápidos y reduce los costos de intermediarios." ;;
    *"Cybersecurity"*) echo "Mejores Prácticas de Ciberseguridad|En la era digital actual, la ciberseguridad es más crítica que nunca. Las organizaciones deben implementar enfoques de seguridad de múltiples capas, auditorías de seguridad regulares y capacitación de empleados para protegerse contra las amenazas cibernéticas en evolución." ;;
    *"Remote Work"*) echo "Revolución del Trabajo Remoto|El cambio al trabajo remoto ha transformado la forma en que las empresas operan a nivel mundial. Las herramientas de colaboración en la nube, los horarios flexibles y las plataformas de comunicación digital permiten la productividad mientras se mantiene el equilibrio entre el trabajo y la vida personal." ;;
    *"Sustainable Energy"*) echo "Soluciones de Energía Sostenible|Las fuentes de energía renovable como la solar y la eólica se están convirtiendo en alternativas cada vez más viables a los combustibles fósiles. La inversión en infraestructura de energía limpia es crucial para combatir el cambio climático." ;;
    *"E-commerce"*) echo "Tendencias de Comercio Electrónico 2025|Las compras en línea continúan evolucionando con recomendaciones impulsadas por IA, pruebas de realidad aumentada y opciones de entrega el mismo día. El comercio móvil está impulsando el futuro del comercio minorista." ;;
    *"Digital Marketing"*) echo "Estrategias de Marketing Digital|El marketing moderno aprovecha el análisis de datos, el compromiso en redes sociales y el contenido personalizado para llegar a las audiencias objetivo. Comprender el comportamiento del cliente es clave para campañas exitosas." ;;
    *"Quantum Computing"*) echo "Avances en Computación Cuántica|La computación cuántica promete resolver problemas complejos que actualmente son intratables para las computadoras clásicas. Las aplicaciones van desde el descubrimiento de medicamentos hasta la criptografía." ;;
    *"5G Network"*) echo "Tecnología de Red 5G|La tecnología inalámbrica de quinta generación ofrece velocidades más rápidas, menor latencia y admite el creciente ecosistema del Internet de las Cosas. Esto permite ciudades inteligentes y vehículos autónomos." ;;
    *"Biotechnology"*) echo "Innovaciones en Biotecnología|Los avances en edición genética, medicina personalizada y biología sintética están transformando la atención médica. La tecnología CRISPR abre nuevas posibilidades para tratar enfermedades genéticas." ;;
    *"Space Exploration"*) echo "Actualizaciones de Exploración Espacial|Las empresas privadas se están uniendo a las agencias gubernamentales en la nueva carrera espacial. La colonización de Marte, las bases lunares y el turismo espacial se están convirtiendo en objetivos realistas." ;;
    *) echo "Título Placeholder - Español|Este es un contenido placeholder en español. Contenido de artículo para probar la funcionalidad multilingüe de Polylang." ;;
  esac
}

# Create a single post in a specific language
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

# Main function to create multilingual post set
create_multilang_post_set() {
  local index=$1
  local template="${ARTICLE_TEMPLATES[$index]}"
  local author_id=$2

  # Parse template
  IFS='|' read -r en_title en_content <<< "$template"

  log_info "Creating multilingual post set: $en_title"

  # Generate slug
  local base_slug=$(title_to_slug "$en_title")

  # Step 1: Create EN post
  log_info "  [1/6] Creating English post..."
  local en_id=$(create_post "$en_title" "$base_slug" "$en_content" "$author_id")

  if [ "$en_id" -eq 0 ]; then
    log_error "Failed to create English post. Skipping this set."
    return 1
  fi
  log_success "  Created EN post: ID=$en_id"

  # Step 2: Create ZH post
  log_info "  [2/6] Creating Chinese post..."
  local zh_data=$(get_zh_translation "$en_title" "$en_content")
  IFS='|' read -r zh_title zh_content <<< "$zh_data"
  local zh_slug="${base_slug}-zh"
  local zh_id=$(create_post "$zh_title" "$zh_slug" "$zh_content" "$author_id")

  if [ "$zh_id" -eq 0 ]; then
    log_error "Failed to create Chinese post. Skipping this set."
    wp post delete "$en_id" --force > /dev/null
    return 1
  fi
  log_success "  Created ZH post: ID=$zh_id"

  # Step 3: Create ES post
  log_info "  [3/6] Creating Spanish post..."
  local es_data=$(get_es_translation "$en_title" "$en_content")
  IFS='|' read -r es_title es_content <<< "$es_data"
  local es_slug="${base_slug}-es"
  local es_id=$(create_post "$es_title" "$es_slug" "$es_content" "$author_id")

  if [ "$es_id" -eq 0 ]; then
    log_error "Failed to create Spanish post. Skipping this set."
    wp post delete "$en_id" --force > /dev/null
    wp post delete "$zh_id" --force > /dev/null
    return 1
  fi
  log_success "  Created ES post: ID=$es_id"

  # Step 4: Assign language terms
  log_info "  [4/6] Assigning language terms..."
  wp post term set "$en_id" language en > /dev/null 2>&1
  wp post term set "$zh_id" language zh > /dev/null 2>&1
  wp post term set "$es_id" language es > /dev/null 2>&1
  log_success "  Language terms assigned"

  # Step 5: Create translation group
  log_info "  [5/6] Creating translation group..."
  local trans_group="pll_$(openssl rand -hex 6)"
  local desc="a:3:{s:2:\"en\";i:$en_id;s:2:\"zh\";i:$zh_id;s:2:\"es\";i:$es_id;}"

  wp term create post_translations "$trans_group" \
    --slug="$trans_group" \
    --description="$desc" > /dev/null 2>&1

  wp post term set "$en_id" post_translations "$trans_group" > /dev/null 2>&1
  wp post term set "$zh_id" post_translations "$trans_group" > /dev/null 2>&1
  wp post term set "$es_id" post_translations "$trans_group" > /dev/null 2>&1

  log_success "  Translation group created: $trans_group"

  # Step 6: Add featured images
  log_info "  [6/6] Adding featured images..."
  local img_index=$((index % ${#FEATURED_IMAGES[@]}))
  local img_id=${FEATURED_IMAGES[$img_index]}

  wp post meta update "$en_id" _thumbnail_id "$img_id" > /dev/null 2>&1
  wp post meta update "$zh_id" _thumbnail_id "$img_id" > /dev/null 2>&1
  wp post meta update "$es_id" _thumbnail_id "$img_id" > /dev/null 2>&1

  log_success "  Featured images added (Image ID: $img_id)"

  echo ""
  log_success "✓ Post set created successfully!"
  echo "  EN: ID=$en_id | $en_title"
  echo "  ZH: ID=$zh_id | $zh_title"
  echo "  ES: ID=$es_id | $es_title"
  echo "  Translation Group: $trans_group"
  echo ""

  # Store for summary
  CREATED_POSTS+=("$en_id,$zh_id,$es_id,$trans_group")
}

################################################################################
# Main Script
################################################################################

echo ""
echo "=========================================="
echo "  Polylang Multi-language Post Creator"
echo "=========================================="
echo ""

# Validate post count
if ! [[ "$POST_COUNT" =~ ^[0-9]+$ ]] || [ "$POST_COUNT" -lt 1 ] || [ "$POST_COUNT" -gt 10 ]; then
  log_error "Invalid post count. Must be between 1 and 10."
  exit 1
fi

log_info "Configuration:"
echo "  - Posts to create: $POST_COUNT"
echo "  - Featured images: ${FEATURED_IMAGES[*]}"
echo ""

# Get author
log_info "Getting author information..."
AUTHOR_ID=$(get_author_id)
AUTHOR_LOGIN=$(wp user get "$AUTHOR_ID" --field=user_login)
log_success "Author found: $AUTHOR_LOGIN (ID: $AUTHOR_ID)"
echo ""

# Array to store created posts
declare -a CREATED_POSTS=()

# Create posts
log_info "Starting post creation..."
echo ""

for ((i=0; i<POST_COUNT; i++)); do
  log_info "--- Creating post set $((i+1))/$POST_COUNT ---"
  create_multilang_post_set "$i" "$AUTHOR_ID"
done

# Flush rewrite rules
log_info "Flushing rewrite rules..."
wp rewrite flush > /dev/null 2>&1
log_success "Rewrite rules flushed"
echo ""

# Summary
echo "=========================================="
echo "  Summary"
echo "=========================================="
echo ""
log_success "Created $POST_COUNT multilingual post sets (${#CREATED_POSTS[@]} sets)"
echo ""

for post_set in "${CREATED_POSTS[@]}"; do
  IFS=',' read -r en_id zh_id es_id trans_group <<< "$post_set"
  echo "  Translation Group: $trans_group"
  echo "    EN: http://cccc.local/$(wp post get "$en_id" --field=post_name)/"
  echo "    ZH: http://cccc.local/zh/$(wp post get "$zh_id" --field=post_name)/"
  echo "    ES: http://cccc.local/es/$(wp post get "$es_id" --field=post_name)/"
  echo ""
done

log_success "All done! 🎉"
echo ""
