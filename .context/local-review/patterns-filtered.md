# Filtered Anti-patterns (Lv.2+)

profile/static-site 系で関連するアンチパターンのみ抽出。

## Lv.2 — Markdown / HTML / GitHub Pages

- **Sanitization 前提違反**: GitHub README は `<style>` `<script>` `on*` 属性をすべて剥がす。markdown 内で hover/animation を CSS で実現しようとする実装は黒 box になる。
- **外部リソース過剰依存**: shields.io / komarev / vercel.app など 7+ 個の外部サービスに依存する README は 1 サービスダウンで描画崩れ。
- **画像 width/height 不一致**: img の width 属性と src 側の実画像サイズが大きく乖離するとレイアウトずれ・LCP 悪化。
- **無効 markdown HTML 属性**: `align="center"` は HTML5 で deprecated だが GitHub markdown では現状動く。`<br/>` の自己終了形は OK、`<br>` も OK。

## Lv.2 — GitHub Actions / Workflow

- **Floating ref で action pinning**: `uses: foo/bar@master` は supply chain リスク。`@v1` か commit SHA 固定が望ましい。
- **secret 漏洩リスク**: workflow log への secret 印字、`run: echo ${{ secrets.X }}` は禁止。
- **permissions 未宣言**: `permissions:` を job レベルで宣言しないと GITHUB_TOKEN がデフォルト書込になる（リポ設定次第）。
- **cron schedule 重複**: 複数 workflow で同時刻 cron は GitHub Actions 並列スロット競合。

## Lv.3 — 設計判断

- **SVG 内の外部リソース参照**: SVG 内 `<image href="https://...">` は GitHub の raw 配信で CORS / sanitization 制約あり。
- **GitHub Pages の jekyll 干渉**: `/docs` ルートで Jekyll が走り、underscore 始まりファイルが除外される。`.nojekyll` ファイル不在で動作不能になることがある。
- **CDN / fonts ブロッキング**: Google Fonts 等の external font は CSP 厳格 repo で blocked。OS フォントスタック fallback 必須。
