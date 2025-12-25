#!/usr/bin/env bun

/**
 * ====================================================================
 * WordPress 完整翻译系统 / Complete WordPress Translation System
 * ====================================================================
 *
 * 一键自动翻译WordPress文章到多语言，自动生成SEO元数据，自动配置Polylang关联
 * Auto-translate WordPress posts to multiple languages with SEO meta and Polylang integration
 *
 * ====================================================================
 * 功能特性 / Features
 * ====================================================================
 *
 * ✅ 并行翻译 - 同时翻译多语言，速度快
 * ✅ 智能跳过 - 自动检测已存在的翻译，避免重复
 * ✅ SEO优化 - 为每个语言版本生成专业的SEO标题和描述
 * ✅ Polylang集成 - 自动配置语言关联关系
 * ✅ Slug管理 - 为不同语言版本添加语言后缀（如：-es, -de）
 * ✅ 日期随机化 - 翻译文章发布日期随机偏移1-7天
 * ✅ 行业专用 - 针对PCB/PCBA制造业优化翻译质量
 * ✅ HTML保护 - 完美保留所有HTML标签和格式
 *
 * ====================================================================
 * 环境要求 / Requirements
 * ====================================================================
 *
 * - Bun runtime (v1.0+)
 * - WordPress with WP-CLI
 * - Polylang plugin installed and activated
 * - SEOPress plugin (for SEO meta)
 * - AI API key (aihubmix.com or OpenAI compatible)
 *
 * ====================================================================
 * 安装配置 / Installation
 * ====================================================================
 *
 * 1. 安装 Bun runtime:
 *    curl -fsSL https://bun.sh/install | bash
 *
 * 2. 配置 AI API Key:
 *    export AI_API_KEY="your-api-key-here"
 *
 *    或添加到 ~/.bashrc 或 ~/.zshrc:
 *    echo 'export AI_API_KEY="your-api-key-here"' >> ~/.bashrc
 *
 * 3. 确认 WordPress 环境:
 *    wp core version        # 检查WordPress版本
 *    wp plugin list         # 确认Polylang已安装
 *
 * ====================================================================
 * 使用方法 / Usage
 * ====================================================================
 *
 * 基本用法:
 *   bun translate-complete.ts <post-id>
 *
 *   示例: bun translate-complete.ts 28112
 *   效果: 翻译文章28112到所有语言（cs, de, es, pt, ru）
 *
 * 指定语言:
 *   bun translate-complete.ts <post-id> --langs=es,pt,de
 *
 *   示例: bun translate-complete.ts 28112 --langs=es,pt
 *   效果: 只翻译到西班牙语和葡萄牙语
 *
 * 包含中文翻译:
 *   bun translate-complete.ts <post-id> --include-zh
 *
 *   示例: bun translate-complete.ts 28112 --include-zh
 *   效果: 翻译到所有语言，包括中文（默认跳过中文）
 *
 * ====================================================================
 * 支持的语言 / Supported Languages
 * ====================================================================
 *
 * - en: English (英语)
 * - cs: Czech (捷克语)
 * - de: German (德语)
 * - es: Spanish (西班牙语)
 * - pt: Portuguese (葡萄牙语)
 * - ru: Russian (俄语)
 * - zh: Chinese Simplified (简体中文) - 默认跳过，可用 --include-zh 启用
 *
 * ====================================================================
 * 批量翻译 / Batch Translation
 * ====================================================================
 *
 * 翻译多篇文章:
 *   for id in 28112 26918 26373; do
 *     bun translate-complete.ts $id
 *     echo "---"
 *   done
 *
 * 翻译所有英文文章:
 *   wp post list --post_type=post --lang=en --field=ID | while read id; do
 *     echo "翻译文章 $id..."
 *     bun translate-complete.ts $id
 *   done
 *
 * ====================================================================
 * 工作流程 / Workflow
 * ====================================================================
 *
 * 1. 读取原文 - 获取文章标题、内容、摘要、元数据
 * 2. 检查已有翻译 - 避免重复翻译已存在的语言版本
 * 3. 并行翻译 - 同时翻译标题、内容、摘要到所有目标语言
 * 4. 创建文章 - 为每个语言创建新文章，设置slug后缀
 * 5. 生成SEO - 为每个语言版本生成专业的SEO元数据
 * 6. 配置关联 - 更新Polylang翻译关系，关联所有语言版本
 *
 * ====================================================================
 * 常见问题 / Troubleshooting
 * ====================================================================
 *
 * Q: 提示 "AI_API_KEY not found"
 * A: 运行 export AI_API_KEY="your-key" 设置API密钥
 *
 * Q: WP-CLI命令失败
 * A: 确保在WordPress根目录运行，检查wp命令是否可用
 *
 * Q: 翻译重复或覆盖
 * A: 程序会自动检测已有翻译并跳过，不会重复创建
 *
 * Q: 如何验证翻译结果
 * A: 登录WordPress后台，检查文章列表，使用Polylang语言切换器
 *
 * Q: SEO元数据在哪里
 * A: 在SEOPress插件的设置中，每篇文章都有独立的SEO标题和描述
 *
 * ====================================================================
 * 注意事项 / Important Notes
 * ====================================================================
 *
 * ⚠️ "Auspi" 是公司名称，在所有语言中都保持不变，不翻译
 * ⚠️ API调用需要费用，请注意使用量
 * ⚠️ 翻译大文章可能需要较长时间，请耐心等待
 * ⚠️ 确保WordPress数据库有备份
 * ⚠️ 首次使用建议在测试环境验证
 *
 * ====================================================================
 * 技术说明 / Technical Details
 * ====================================================================
 *
 * - API端点: https://aihubmix.com/v1/chat/completions
 * - 翻译模型: GPT-4o
 * - 并行度: 所有目标语言同时翻译
 * - SEO生成: JSON mode，确保结构化输出
 * - Polylang: 使用term_id（不是slug）更新关联关系
 * - Slug格式: 原slug + 语言后缀（例：what-is-pcba-es）
 *
 * ====================================================================
 * 版本信息 / Version
 * ====================================================================
 *
 * Version: 2.0
 * Last Updated: 2025-12-25
 * Author: AUSPI Translation Automation
 * License: Proprietary
 *
 * ====================================================================
 */

import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

// Configuration
const API_KEY = process.env.AI_API_KEY || '';
const API_ENDPOINT = 'https://aihubmix.com/v1/chat/completions';
const MODEL = 'gpt-4o';

// Skip Chinese by default (can be overridden)
const DEFAULT_TARGET_LANGS = ['cs', 'de', 'es', 'pt', 'ru'];
const SKIP_LANGUAGE = 'zh'; // Don't translate to Chinese

// Company context
const COMPANY_CONTEXT = `
AUSPI Company Background:
Founded in 2003, AUSPI is a high-tech enterprise specializing in PCB design, manufacturing, and assembly services. As a leading partner in the PCB manufacturing and assembly (PCBA) sector, we pride ourselves on delivering the highest quality solutions at flexible and competitive prices. Our expertise spans various industries, including medical, telecommunications, automotive, Energy, transportation and more, with operations and manufacturing facilities strategically located across the USA, Europe, and Asia.

At AUSPI, we are dedicated to meeting the unique needs of our customers. We offer a comprehensive range of services, including rigid, flex, and rigid-flex circuits, as well as box builds. Whether you require quick-turn prototypes, short-run production, or high-volume manufacturing, our agile approach ensures we can handle your toughest requirements with efficiency and precision.

IMPORTANT: "Auspi" is the company name and should NEVER be translated. Keep it as "Auspi" in all languages.
`;

const LANGUAGE_NAMES: Record<string, string> = {
  en: 'English',
  zh: 'Chinese (Simplified)',
  es: 'Spanish',
  pt: 'Portuguese',
  de: 'German',
  ru: 'Russian',
  cs: 'Czech',
};

interface PostData {
  title: string;
  content: string;
  excerpt: string;
  status: string;
  author: number;
  language: string;
  postDate: string;
  slug: string;
}

interface TranslationResult {
  lang: string;
  postId: number;
  title: string;
  slug: string;
}

/**
 * Translate text using AI
 */
async function translateText(
  text: string,
  sourceLang: string,
  targetLang: string
): Promise<string> {
  const sourceName = LANGUAGE_NAMES[sourceLang] || sourceLang;
  const targetName = LANGUAGE_NAMES[targetLang] || targetLang;

  const prompt = `You are a professional translator specializing in technical and business content for the PCB/PCBA manufacturing industry.

${COMPANY_CONTEXT}

The content you are translating is related to PCB design, manufacturing, and assembly services. Please ensure technical terms are translated accurately according to industry standards.

Translate the following text from ${sourceName} to ${targetName}.

CRITICAL RULES:
1. Preserve all HTML tags EXACTLY as they are (including <img>, <a>, <div>, <!-- -->, etc.)
2. Do NOT translate any content inside HTML tags or attributes
3. Only translate the visible text content between tags
4. Maintain the same formatting and structure
5. Keep technical PCB/PCBA terms accurate
6. Preserve line breaks and paragraphs
7. Do NOT add any extra content or explanations
8. Return ONLY the translated text
9. NEVER translate "Auspi" - it's a company name, keep it as "Auspi"

Text to translate:
${text}

Translated text:`;

  const response = await fetch(API_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${API_KEY}`,
    },
    body: JSON.stringify({
      model: MODEL,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.3,
      max_tokens: 4000,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Translation API error (${response.status}): ${error}`);
  }

  const data = await response.json();
  return data.choices?.[0]?.message?.content?.trim() || '';
}

/**
 * Generate SEO meta using AI
 */
async function generateSEOMeta(
  postTitle: string,
  postContent: string,
  targetLang: string
): Promise<{ title: string; description: string }> {
  const targetName = LANGUAGE_NAMES[targetLang] || targetLang;

  const limits: Record<string, { titleChars: string; descChars: string }> = {
    zh: { titleChars: '25-30 characters', descChars: '70-80 characters' },
    ja: { titleChars: '25-30 characters', descChars: '70-80 characters' },
    ko: { titleChars: '25-30 characters', descChars: '70-80 characters' },
    default: { titleChars: '50-60 characters', descChars: '150-160 characters' },
  };

  const limit = limits[targetLang] || limits.default;

  const prompt = `You are an SEO expert specializing in PCB/PCBA manufacturing industry content.

${COMPANY_CONTEXT}

Generate SEO meta tags in ${targetName} for the following article.

Article Title: ${postTitle}
Article Content: ${postContent.substring(0, 1000)}...

Requirements:
1. SEO Title: ${limit.titleChars}, compelling and includes main keyword
2. SEO Description: ${limit.descChars}, engaging and includes call-to-action
3. NEVER translate "Auspi" - keep it as "Auspi"
4. Focus on PCB/PCBA industry keywords
5. Make it click-worthy and search-engine friendly
6. Include a call-to-action or benefit statement

Return ONLY a valid JSON object with this exact structure:
{
  "title": "SEO title here",
  "description": "SEO description here"
}`;

  const response = await fetch(API_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${API_KEY}`,
    },
    body: JSON.stringify({
      model: MODEL,
      messages: [{ role: 'user', content: prompt }],
      response_format: { type: 'json_object' },
      temperature: 0.5,
      max_tokens: 300,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`SEO API error (${response.status}): ${error}`);
  }

  const data = await response.json();
  const seoMeta = JSON.parse(data.choices?.[0]?.message?.content || '{}');

  if (!seoMeta.title || !seoMeta.description) {
    throw new Error('Invalid SEO meta structure');
  }

  return {
    title: seoMeta.title.trim(),
    description: seoMeta.description.trim(),
  };
}

/**
 * Get existing translations for a post
 */
async function getExistingTranslations(postId: number): Promise<string[]> {
  try {
    // Get translation group description
    const { stdout } = await execAsync(
      `wp post term list ${postId} post_translations --field=description`
    );

    if (!stdout.trim()) {
      return [];
    }

    // Parse PHP serialized data to extract language codes
    // Format: a:6:{s:2:"en";i:26918;s:2:"es";i:29225;...}
    const description = stdout.trim();
    const langMatches = description.match(/s:2:"([a-z]{2})";/g);

    if (!langMatches) {
      return [];
    }

    return langMatches
      .map((match) => {
        const langMatch = match.match(/s:2:"([a-z]{2})";/);
        return langMatch ? langMatch[1] : '';
      })
      .filter(Boolean);
  } catch (error) {
    // No translation group exists
    return [];
  }
}

/**
 * Get post data
 */
async function getPostData(postId: number): Promise<PostData> {
  try {
    const [title, content, excerpt, status, author, language, postDate, slug] =
      await Promise.all([
        execAsync(`wp post get ${postId} --field=post_title`).then((r) =>
          r.stdout.trim()
        ),
        execAsync(`wp post get ${postId} --field=post_content`).then((r) =>
          r.stdout.trim()
        ),
        execAsync(`wp post get ${postId} --field=post_excerpt`).then((r) =>
          r.stdout.trim()
        ),
        execAsync(`wp post get ${postId} --field=post_status`).then((r) =>
          r.stdout.trim()
        ),
        execAsync(`wp post get ${postId} --field=post_author`).then((r) =>
          r.stdout.trim()
        ),
        execAsync(`wp post term list ${postId} language --field=slug`).then(
          (r) => r.stdout.trim()
        ),
        execAsync(`wp post get ${postId} --field=post_date`).then((r) =>
          r.stdout.trim()
        ),
        execAsync(`wp post get ${postId} --field=post_name`).then((r) =>
          r.stdout.trim()
        ),
      ]);

    return {
      title,
      content,
      excerpt,
      status,
      author: parseInt(author),
      language,
      postDate,
      slug,
    };
  } catch (error) {
    throw new Error(`Failed to get post data: ${error.message}`);
  }
}

/**
 * Create translated post with slug suffix
 */
async function createTranslatedPost(
  originalData: PostData,
  targetLang: string,
  translatedTitle: string,
  translatedContent: string,
  translatedExcerpt: string
): Promise<number> {
  // Add random 1-7 days offset
  const originalDate = new Date(originalData.postDate);
  const daysOffset = Math.floor(Math.random() * 7) + 1;
  const newDate = new Date(originalDate);
  newDate.setDate(originalDate.getDate() + daysOffset);
  const formattedDate = newDate.toISOString().slice(0, 19).replace('T', ' ');

  // Create slug with language suffix
  const newSlug = `${originalData.slug}-${targetLang}`;

  const { stdout } = await execAsync(
    `wp post create --post_type=post --post_title="${translatedTitle.replace(
      /"/g,
      '\\"'
    )}" --post_content="${translatedContent.replace(
      /"/g,
      '\\"'
    )}" --post_excerpt="${translatedExcerpt.replace(
      /"/g,
      '\\"'
    )}" --post_status=${
      originalData.status
    } --post_author=${
      originalData.author
    } --post_date="${formattedDate}" --post_name="${newSlug}" --porcelain`
  );

  const newPostId = parseInt(stdout.trim());

  // Set language
  await execAsync(
    `wp post term set ${newPostId} language ${targetLang} --by=slug`
  );

  return newPostId;
}

/**
 * Write SEO meta to post
 */
async function writeSEOMeta(
  postId: number,
  title: string,
  description: string
): Promise<void> {
  await Promise.all([
    execAsync(
      `wp post meta update ${postId} _seopress_titles_title "${title.replace(
        /"/g,
        '\\"'
      )}"`
    ),
    execAsync(
      `wp post meta update ${postId} _seopress_titles_desc "${description.replace(
        /"/g,
        '\\"'
      )}"`
    ),
  ]);
}

/**
 * Update Polylang translation relationships
 */
async function updateTranslationRelationships(
  postIds: Record<string, number>
): Promise<void> {
  const langs = Object.keys(postIds).sort();
  const pairs = langs
    .map((lang) => `s:2:"${lang}";i:${postIds[lang]};`)
    .join('');
  const serialized = `a:${langs.length}:{${pairs}}`;

  const firstPostId = Object.values(postIds)[0];

  // Try to get existing translation term ID (not slug!)
  let termId: string | null = null;
  try {
    const { stdout } = await execAsync(
      `wp post term list ${firstPostId} post_translations --field=term_id`
    );
    termId = stdout.trim();
  } catch (error) {
    // No existing term
  }

  if (termId) {
    // Update existing term using term_id
    await execAsync(
      `wp term update post_translations ${termId} --description='${serialized}'`
    );
  } else {
    // Create new term
    const termSlug = `pll_${Date.now().toString(16)}`;
    await execAsync(
      `wp term create post_translations "${termSlug}" --description='${serialized}'`
    );
    // Get the newly created term_id
    const { stdout } = await execAsync(
      `wp term list post_translations --slug=${termSlug} --field=term_id`
    );
    termId = stdout.trim();
  }

  // Assign to all posts in parallel using term_id
  await Promise.all(
    Object.values(postIds).map((postId) =>
      execAsync(`wp post term set ${postId} post_translations ${termId} --by=id`)
    )
  );
}

/**
 * Translate to one language (parallel execution)
 */
async function translateToLanguage(
  originalData: PostData,
  targetLang: string
): Promise<TranslationResult> {
  console.log(`\n🔄 [${targetLang.toUpperCase()}] Starting translation...`);

  // Parallel translate title, content, excerpt
  const [translatedTitle, translatedContent, translatedExcerpt] =
    await Promise.all([
      translateText(originalData.title, originalData.language, targetLang),
      translateText(originalData.content, originalData.language, targetLang),
      originalData.excerpt
        ? translateText(originalData.excerpt, originalData.language, targetLang)
        : Promise.resolve(''),
    ]);

  console.log(`   ✅ [${targetLang.toUpperCase()}] Translation completed`);

  // Create post
  console.log(`   📄 [${targetLang.toUpperCase()}] Creating post...`);
  const newPostId = await createTranslatedPost(
    originalData,
    targetLang,
    translatedTitle,
    translatedContent,
    translatedExcerpt
  );

  const newSlug = `${originalData.slug}-${targetLang}`;
  console.log(
    `   ✅ [${targetLang.toUpperCase()}] Post created: ID=${newPostId}, slug=${newSlug}`
  );

  // Generate and write SEO meta in parallel
  console.log(`   🎯 [${targetLang.toUpperCase()}] Generating SEO meta...`);
  const seoMeta = await generateSEOMeta(
    translatedTitle,
    translatedContent,
    targetLang
  );

  await writeSEOMeta(newPostId, seoMeta.title, seoMeta.description);
  console.log(`   ✅ [${targetLang.toUpperCase()}] SEO meta written`);
  console.log(`      Title: ${seoMeta.title.substring(0, 50)}...`);

  return {
    lang: targetLang,
    postId: newPostId,
    title: translatedTitle,
    slug: newSlug,
  };
}

/**
 * Main function
 */
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log(`
🚀 Complete WordPress Translation System

Usage: bun translate-complete.ts <post-id> [options]

Options:
  --langs=cs,de,es    Specify target languages (default: cs,de,es,pt,ru)
  --include-zh        Include Chinese translation (default: skip)

Examples:
  bun translate-complete.ts 28112
  bun translate-complete.ts 28112 --langs=es,pt,de
  bun translate-complete.ts 28112 --include-zh

Default target languages: cs, de, es, pt, ru (zh is skipped by default)
    `);
    process.exit(1);
  }

  const postId = parseInt(args[0]);
  const includeZh = args.includes('--include-zh');

  let targetLangs = DEFAULT_TARGET_LANGS;

  // Parse custom languages
  const langsArg = args.find((arg) => arg.startsWith('--langs='));
  if (langsArg) {
    targetLangs = langsArg.split('=')[1].split(',');
  }

  // Add zh if requested
  if (includeZh && !targetLangs.includes('zh')) {
    targetLangs.push('zh');
  }

  if (isNaN(postId)) {
    console.error('❌ Error: Invalid post ID');
    process.exit(1);
  }

  if (!API_KEY) {
    console.error('❌ Error: AI_API_KEY not found in environment');
    process.exit(1);
  }

  console.log('🚀 Complete WordPress Translation System');
  console.log('='.repeat(60));
  console.log(`📝 Post ID: ${postId}`);
  console.log(`🌍 Target languages: ${targetLangs.join(', ')}`);
  console.log(`🤖 AI Model: ${MODEL}`);
  console.log(`⚡ Parallel processing: ENABLED`);
  console.log('='.repeat(60));

  const startTime = Date.now();

  try {
    // Get original post data
    console.log('\n📖 Reading original post...');
    const originalData = await getPostData(postId);

    console.log(`   Title: ${originalData.title.substring(0, 60)}...`);
    console.log(`   Language: ${originalData.language}`);
    console.log(`   Slug: ${originalData.slug}`);
    console.log(`   Status: ${originalData.status}`);

    // Check existing translations
    console.log('\n🔍 Checking existing translations...');
    const existingLangs = await getExistingTranslations(postId);

    if (existingLangs.length > 0) {
      console.log(`   ✅ Found existing translations: ${existingLangs.join(', ')}`);
    } else {
      console.log('   ℹ️  No existing translations found');
    }

    // Filter out source language AND existing translations
    const validTargetLangs = targetLangs.filter(
      (lang) => lang !== originalData.language && !existingLangs.includes(lang)
    );

    if (validTargetLangs.length === 0) {
      console.log('\n✅ All requested languages already exist! Nothing to translate.');
      console.log(`   Existing: ${existingLangs.join(', ')}`);
      process.exit(0);
    }

    console.log(
      `\n🚀 Starting parallel translation to ${validTargetLangs.length} languages...`
    );
    console.log(`   Will translate: ${validTargetLangs.join(', ')}`);
    if (existingLangs.length > 0) {
      console.log(`   Skipping existing: ${existingLangs.join(', ')}`);
    }

    // PARALLEL TRANSLATION - All languages at once!
    const results = await Promise.all(
      validTargetLangs.map((lang) => translateToLanguage(originalData, lang))
    );

    console.log('\n✅ All translations completed!');

    // Build translation map - include existing translations!
    const translationMap: Record<string, number> = {
      [originalData.language]: postId,
    };

    // Get existing translation post IDs
    if (existingLangs.length > 0) {
      try {
        const { stdout } = await execAsync(
          `wp post term list ${postId} post_translations --field=description`
        );
        const description = stdout.trim();

        // Parse existing translation IDs: a:6:{s:2:"en";i:26918;s:2:"es";i:29225;...}
        const matches = description.match(/s:2:"([a-z]{2})";i:(\d+);/g);
        if (matches) {
          matches.forEach((match) => {
            const parsed = match.match(/s:2:"([a-z]{2})";i:(\d+);/);
            if (parsed) {
              translationMap[parsed[1]] = parseInt(parsed[2]);
            }
          });
        }
      } catch (error) {
        console.warn('   ⚠️  Warning: Could not fetch existing translation IDs');
      }
    }

    // Add new translations
    results.forEach((result) => {
      translationMap[result.lang] = result.postId;
    });

    // Update Polylang relationships
    console.log('\n🔗 Updating Polylang translation relationships...');
    await updateTranslationRelationships(translationMap);
    console.log('   ✅ Translation relationships updated');

    const elapsedTime = ((Date.now() - startTime) / 1000).toFixed(1);

    console.log('\n' + '='.repeat(60));
    console.log('✅ TRANSLATION COMPLETED SUCCESSFULLY!');
    console.log('='.repeat(60));
    console.log(`⏱️  Total time: ${elapsedTime}s`);
    console.log(`📊 Languages processed: ${validTargetLangs.length}`);
    console.log(`⚡ Average time per language: ${(parseFloat(elapsedTime) / validTargetLangs.length).toFixed(1)}s`);
    console.log('\n📋 Translation Map:');

    for (const [lang, id] of Object.entries(translationMap)) {
      const result = results.find((r) => r.lang === lang);
      const slug = result ? result.slug : originalData.slug;
      console.log(`   ${lang}: ${id} (${slug})`);
    }

    console.log('\n🎉 All done! Check your WordPress admin panel.');
    console.log('='.repeat(60));
  } catch (error) {
    console.error('\n❌ Translation failed:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

main();
