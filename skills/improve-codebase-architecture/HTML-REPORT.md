# HTML 报告格式

架构审查报告渲染为操作系统临时目录中的单个自包含 HTML 文件。Tailwind 和 Mermaid 均通过 CDN 加载。Mermaid 能可靠处理图结构；手工构建的 div 和内联 SVG 则负责更具编辑设计感的视觉图形（质量图、横截面图）。两者应混合使用——不要所有内容都依赖 Mermaid，否则报告会显得千篇一律。

## 脚手架（Scaffold）

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review — {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly:
         dashed seam lines, hand-drawn-feeling arrow heads, etc. */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## 页眉（Header）

包含仓库名称、日期和紧凑图例：实线框 = module，虚线 = seam，红色箭头 = leakage，粗深色框 = deep module。不要写引言段落——直接进入候选项。

## 候选项卡片（Candidate card）

图示承担主要表达任务。文字应少而平实，并自然使用 `/codebase-design` 技能中的术语表词汇。

每个候选项使用一个 `<article>`：

- **标题（Title）**——简短，直接命名深化动作（例如“Collapse the Order intake pipeline”）。
- **徽章行（Badge row）**——显示建议强度（`Strong` = 翠绿色，`Worth exploring` = 琥珀色，`Speculative` = 石板色），再加一个依赖类别标签（`in-process`、`local-substitutable`、`ports & adapters`、`mock`）。
- **文件（Files）**——等宽字体列表，使用 `font-mono text-sm`。
- **前后对比图（Before / After diagram）**——核心内容。两列并排。样式见下文。
- **问题（Problem）**——一句话，说明痛点。
- **方案（Solution）**——一句话，说明变化。
- **收益（Wins）**——项目符号，每项不超过 6 个词。例如“Tests hit one interface”“Pricing logic stops leaking”“Delete 4 shallow wrappers”。
- **ADR 提示（ADR callout）**（如适用）——在琥珀色浅底框中写一行。

不要写解释段落。如果图示必须借助一个段落才能看懂，就重画图示。

## 图示模式（Diagram patterns）

选择适合候选项的模式并混合使用。不要让每张图看起来都一样——多样性本身就是设计目标的一部分。

### Mermaid 图（依赖／调用流的主力）

当重点是“X 调用 Y，Y 再调用 Z，看看有多混乱”时，使用 Mermaid `flowchart` 或 `graph`。用 Tailwind 样式卡片包裹它，避免显得突兀。使用 classDef 把泄漏边标成红色，把深模块标成深色。对于“之前：6 次往返；之后：1 次”，时序图很合适。

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### 手工框线与箭头（当 Mermaid 布局不听使唤时）

模块使用带边框和标签的 `<div>`。箭头使用内联 SVG `<line>` 或 `<path>` 元素，在相对定位容器上绝对定位。当你希望“之后”图呈现一个粗边框深模块、内部结构灰显的感觉时使用这种方式——Mermaid 无法渲染出合适的视觉重量。

### 横截面图（适合表现分层浅薄）

堆叠水平条带（`h-12 border-l-4`），展示一次调用穿过的各层。之前：6 个几乎无所作为的薄层。之后：1 个标有整合后职责的厚条带。

### 质量图（适合“接口与实现一样宽”）

每个模块使用两个矩形——一个表示接口表面积，另一个表示实现。之前：接口矩形几乎与实现矩形一样高（shallow）。之后：接口矩形较矮，实现矩形较高（deep）。

### 调用图折叠（Call-graph collapse）

之前：把函数调用树渲染成嵌套框。之后：把同一棵树折叠进一个框中，并在内部淡化显示现已成为内部细节的调用。

## 风格指南（Style guidance）

- 采用精炼的编辑设计感，而不是企业仪表盘风格。留出充足空白。标题可选用衬线字体（`font-serif` 与 stone/slate 配色很搭）。
- 谨慎使用颜色：一种强调色（翠绿或靛蓝），再用红色表示泄漏、琥珀色表示警告。
- 图示高度保持在约 320px，使前后对比可以舒适地并排展示而无需滚动。
- 图内模块标签使用 `text-xs uppercase tracking-wider`——它们应像示意图，而不是 UI。
- 唯一脚本应为 Tailwind CDN 和 Mermaid ESM 导入。报告其余部分保持静态——没有应用代码，除 Mermaid 自身渲染外不含交互。

## 首要建议小节

使用一张较大的卡片。包含候选项名称、一句理由，以及指向其卡片的锚点链接。仅此而已。

## 语气（Tone）

使用简明、精炼的英语——但架构名词和动词必须直接取自 `/codebase-design` 技能。不能以追求简洁为借口发生术语漂移。

**必须原样使用（Use exactly）：** module、interface、implementation、depth、deep、shallow、seam、adapter、leverage、locality。

**绝不能替换为（Never substitute）：** component、service、unit（代替 module）· API、signature（代替 interface）· boundary（代替 seam）· layer、wrapper（表达 module 时）。

**符合该风格的措辞：**

- "Order intake module is shallow — interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in prod, in-memory in tests."

**收益项目符号（Wins bullets）**应使用术语表词汇命名收益：*“locality: bugs concentrate in one module”*、*“leverage: one interface, N call sites”*、*“interface shrinks; implementation absorbs the wrappers”*。不要写*“easier to maintain”*或*“cleaner code”*——这些表达不在术语表中，不应出现。

不要含糊其辞，不要铺垫，也不要写“it's worth noting that…”。一句话能改成项目符号，就改成项目符号；一个项目符号能删，就删。如果某个词不在 `/codebase-design` 术语表中，先寻找已有词汇，再考虑创造新词。
