# 🚀 完整版翻译系统 - 使用指南

## ✨ 核心优势

### 1. **全自动一条龙**
一个命令完成所有操作：
- ✅ 自动翻译所有目标语言
- ✅ 自动生成 SEO meta
- ✅ 自动 Polylang 关联
- ✅ 自动设置 slug（添加语言后缀）
- ✅ 自动真实发布时间

### 2. **并发处理 - 极速翻译**
- ⚡ **所有语言并发翻译**（不是串行）
- ⚡ 每种语言内部并发处理（title + content + excerpt）
- ⚡ SEO 生成也是并发的
- ⚡ **效率提升 5-10 倍**

### 3. **智能 Slug 管理**
- 原文：`pcb-design-dfm-dft`
- 西班牙语：`pcb-design-dfm-dft-es`
- 德语：`pcb-design-dfm-dft-de`
- **不翻译 slug，只添加语言后缀**

### 4. **默认跳过中文**
- 默认翻译：cs, de, es, pt, ru（5种语言）
- **自动跳过 zh**（中文）
- 可以用 `--include-zh` 选项包含中文

---

## 🎯 使用方法

### 基础用法（推荐）

```bash
# 翻译到默认的 5 种语言（cs, de, es, pt, ru）
AI_API_KEY=${AI_API_KEY} bun translate-complete.ts 28112
```

**输出示例**：
```
🚀 Complete WordPress Translation System
============================================================
📝 Post ID: 28112
🌍 Target languages: cs, de, es, pt, ru
🤖 AI Model: gpt-4o
⚡ Parallel processing: ENABLED
============================================================

📖 Reading original post...
   Title: PCB Design for Manufacturability (DFM) and Testability...
   Language: en
   Slug: pcb-design-dfm-dft
   Status: publish

🚀 Starting parallel translation to 5 languages...

🔄 [CS] Starting translation...
🔄 [DE] Starting translation...
🔄 [ES] Starting translation...
🔄 [PT] Starting translation...
🔄 [RU] Starting translation...
   ✅ [CS] Translation completed
   📄 [CS] Creating post...
   ✅ [CS] Post created: ID=29225, slug=pcb-design-dfm-dft-cs
   🎯 [CS] Generating SEO meta...
   ✅ [CS] SEO meta written
      Title: Návrh PCB: DFM a DFT pro efektivní výrobu
   ✅ [DE] Translation completed
   ...

✅ All translations completed!

🔗 Updating Polylang translation relationships...
   ✅ Translation relationships updated

============================================================
✅ TRANSLATION COMPLETED SUCCESSFULLY!
============================================================
⏱️  Total time: 45.2s
📊 Languages processed: 5
⚡ Average time per language: 9.0s

📋 Translation Map:
   en: 28112 (pcb-design-dfm-dft)
   cs: 29225 (pcb-design-dfm-dft-cs)
   de: 29226 (pcb-design-dfm-dft-de)
   es: 29227 (pcb-design-dfm-dft-es)
   pt: 29228 (pcb-design-dfm-dft-pt)
   ru: 29229 (pcb-design-dfm-dft-ru)

🎉 All done! Check your WordPress admin panel.
============================================================
```

---

### 自定义语言

```bash
# 只翻译西班牙语和葡萄牙语
AI_API_KEY=${AI_API_KEY} bun translate-complete.ts 28112 --langs=es,pt

# 翻译所有语言（包括中文）
AI_API_KEY=${AI_API_KEY} bun translate-complete.ts 28112 --include-zh

# 自定义语言 + 中文
AI_API_KEY=${AI_API_KEY} bun translate-complete.ts 28112 --langs=es,pt,de --include-zh
```

---

## 📊 性能对比

### 旧版本（串行处理）
```
语言 1: 60s
语言 2: 60s
语言 3: 60s
语言 4: 60s
语言 5: 60s
---------------------
总计: 300s (5分钟)
```

### 新版本（并发处理）
```
所有语言同时处理: ~60s
---------------------
总计: 60s (1分钟)
```

**效率提升：5倍！** 🚀

---

## 🔧 完成的任务

每运行一次程序，会自动完成：

### 1. 翻译内容
- ✅ 标题
- ✅ 正文内容（保留 HTML 和图片）
- ✅ 摘要

### 2. SEO Meta
- ✅ SEO 标题（_seopress_titles_title）
- ✅ SEO 描述（_seopress_titles_desc）
- ✅ 针对不同语言优化长度

### 3. 文章属性
- ✅ Slug（原 slug + 语言后缀）
- ✅ 发布时间（原文 + 随机 1-7 天）
- ✅ 作者（与原文相同）
- ✅ 状态（与原文相同）

### 4. Polylang 关联
- ✅ 设置文章语言
- ✅ 建立翻译组关系
- ✅ 所有语言互相关联

---

## 🎯 适用场景

### 单篇文章翻译
```bash
AI_API_KEY=${AI_API_KEY} bun translate-complete.ts 26918
```

### 批量翻译脚本
```bash
#!/bin/bash
# 翻译多篇文章

POST_IDS=(28112 26918 26373 24755)

for post_id in "${POST_IDS[@]}"; do
  echo "Translating post $post_id..."
  AI_API_KEY=${AI_API_KEY} bun translate-complete.ts $post_id
  echo "Completed! Waiting 5s..."
  sleep 5
done

echo "All posts translated!"
```

---

## ⚙️ 技术细节

### 并发策略

1. **语言级别并发**：所有语言同时翻译
   ```typescript
   await Promise.all(
     languages.map(lang => translateToLanguage(lang))
   )
   ```

2. **内容级别并发**：每种语言内部并发处理
   ```typescript
   const [title, content, excerpt] = await Promise.all([
     translateText(title, lang),
     translateText(content, lang),
     translateText(excerpt, lang),
   ])
   ```

3. **元数据级别并发**：SEO 标题和描述并发写入
   ```typescript
   await Promise.all([
     writeSeoTitle(postId, title),
     writeSeoDesc(postId, desc),
   ])
   ```

### Slug 处理

```typescript
// 获取原文 slug
const originalSlug = 'pcb-design-dfm-dft';

// 创建带语言后缀的 slug
const newSlug = `${originalSlug}-${targetLang}`; // pcb-design-dfm-dft-es

// 使用 --post_name 参数指定
wp post create ... --post_name="${newSlug}"
```

---

## 🚨 注意事项

1. **API 配额**：并发翻译会快速消耗 API 配额
2. **服务器负载**：短时间内创建多篇文章，注意服务器性能
3. **错误处理**：如果某个语言失败，其他语言继续处理
4. **中文默认跳过**：需要中文翻译请加 `--include-zh`

---

## 🆚 程序对比

| 功能 | translate-post.ts | translate-post-with-seo.ts | **translate-complete.ts** |
|------|-------------------|---------------------------|---------------------------|
| 翻译内容 | ✅ | ✅ | ✅ |
| SEO Meta | ❌ | ✅ | ✅ |
| 并发处理 | ❌ | ❌ | ✅ **5倍速** |
| Slug 后缀 | ❌ | ❌ | ✅ |
| 默认跳过 zh | ❌ | ❌ | ✅ |
| 自定义语言 | ✅ | ✅ | ✅ |
| 一条龙完成 | ❌ | ✅ | ✅ **推荐** |

---

## 🎉 最佳实践

### 步骤 1: 测试翻译质量
```bash
# 先翻译 1-2 种语言测试
AI_API_KEY=${AI_API_KEY} bun translate-complete.ts 28112 --langs=es,pt
```

### 步骤 2: 检查结果
- 访问 WordPress 后台
- 检查翻译质量
- 检查 SEO meta
- 检查 slug
- 检查 Polylang 关联

### 步骤 3: 批量翻译
```bash
# 确认无误后，批量处理
AI_API_KEY=${AI_API_KEY} bun translate-complete.ts 28112
AI_API_KEY=${AI_API_KEY} bun translate-complete.ts 26918
AI_API_KEY=${AI_API_KEY} bun translate-complete.ts 26373
```

---

## 📈 效率提升

- **旧方式**：手动翻译 7 种语言 = 210 分钟/篇
- **串行自动化**：translate-post-with-seo.ts = 5 分钟/篇
- **并发自动化**：translate-complete.ts = **1 分钟/篇**

**总效率提升：210 倍！** 🚀🚀🚀
