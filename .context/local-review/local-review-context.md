# Local Review Context — PR #4 cardene777/cardene777

## Change Summary
- Branch: feature/profile-svg-typing
- PR: #4 (https://github.com/cardene777/cardene777/pull/4)
- Base: main
- Type: docs / chore (profile README & GitHub Pages site redesign)
- Files: 265 (内 ~258 は profile-summary-card-output/**/*.svg 自動生成タイムスタンプ更新)

## Intent
GitHub プロフィール README を「ターミナル風 markdown + GitHub Pages フルプロフィール (docs/index.html)」に再構成。
PR レビューで HTML プレビューと markdown のズレ指摘を受け、SVG タイピング案を捨て GitHub Pages で HTML フル公開 + README は誘導 + 主要バッジ最低限という設計に切り替え。
さらに後続コミットで joke 位置・3D 単独・Stats 並べ・トロフィー theme=onedark / WakaTime セクション追加・hedgehog 大型化など微調整を重ねた。

## Acceptance Criteria
- README が main で表示崩れなく描画される（GitHub markdown sanitization 範囲内のタグ・属性のみ使用）
- docs/index.html が GitHub Pages の `/docs` フォルダ公開で動作（外部 CSS / 画像参照が相対パス or HTTPS で 404 しない）
- workflow yml (waka-readme / profile-3d / snake) が secret 名・action バージョン・cron schedule で稼働する
- assets/logo-cardene.svg が GitHub README で SVG 描画される（許可属性のみ・外部リソース参照なし）
- profile-summary-card-output/ 配下 SVG は自動生成物なのでレビューしない（path_filters で除外）

## Focus Areas

### README.md (markdown profile)
- GitHub markdown sanitizer 対応: `<style>` `<script>` `on*` イベント・`background-color` 属性は剥がされる前提で <table>/<img>/<a>/<pre> のみ使用しているか
- 外部画像 URL の availability・rate limit 影響 (komarev / shields / readme-typing-svg / streak-stats / activity-graph / trophy / readme-jokes)
- WakaTime セクションの `<!--START_SECTION:waka-->` `<!--END_SECTION:waka-->` マーカー位置と workflow 出力の対応
- align/width/height 属性の HTML5 valid 性

### docs/index.html (GitHub Pages full profile)
- インライン `<style>` と外部 `style.css` の二重ロードによるスタイル衝突
- `display: grid` の grid-template-columns が GitHub Pages の Jekyll markdown processor をスキップして raw HTML として描画される確認
- 全画像 src が HTTPS or 同 repo 相対パス（`/cardene777/` 配下のサブパス問題）
- "[sample] cardene777 の 3D 草に置換予定" テキストの残存（PR スコープ内で消し忘れ?）

### docs/style.css
- `:root` CSS variables と body/nav/h1/h2/h3 の適用範囲が docs/index.html 側のインライン style と競合しないか
- Google Fonts / 外部フォント参照なし（@font-face なし）の確認 → JetBrains Mono は OS install 前提

### .github/workflows/*.yml
- waka-readme.yml: `anmol098/waka-readme-stats@master` が tag pinning なしの floating ref → supply chain リスク
- profile-3d.yml: `git push` の credential（GITHUB_TOKEN の content write 権限が permission ブロックで宣言されているか）
- snake.yml: outputs の `palette=github-light&color_snake=...` URL クエリパラメータの YAML エスケープ

### assets/logo-cardene.svg
- `<style><![CDATA[ ... ]]></style>` が GitHub markdown img 経由で描画されるか（GitHub raw SVG は CSS animation を許可するが style blockのインライン `@keyframes` は条件付き）
- glow フィルタの SVG sanitization

## Known Constraints
- ベース main の `images/stat.svg` 差分 (+74/-31) は手動編集ではなく外部生成物 → レビュー対象外
- profile-summary-card-output/ 配下は GitHub Action で自動更新され続けるためレビュー対象外（.coderabbit.yaml の path_filters で除外）

## Changed Files (実質レビュー対象)
- README.md (+145/-104)
- docs/index.html (+136/-0) [新規]
- docs/style.css (+199/-0) [新規]
- assets/logo-cardene.svg (+42/-0) [新規]
- .github/workflows/waka-readme.yml (+34/-0) [新規]
- .github/workflows/profile-3d.yml (+32/-0) [新規]
- .github/workflows/snake.yml (+4/-14)
- profile-3d-contrib/settings.json (+11/-0) [新規]

## Review History
Round 1 (初回)
