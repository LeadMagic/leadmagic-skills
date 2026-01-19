# VS Code Setup

Configure VS Code for Biome integration.

## Install Extension

Install the [Biome VS Code extension](https://marketplace.visualstudio.com/items?itemName=biomejs.biome).

## Workspace Settings

```json
// .vscode/settings.json
{
  "editor.defaultFormatter": "biomejs.biome",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "quickfix.biome": "explicit",
    "source.organizeImports.biome": "explicit"
  },
  "[javascript]": {
    "editor.defaultFormatter": "biomejs.biome"
  },
  "[typescript]": {
    "editor.defaultFormatter": "biomejs.biome"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "biomejs.biome"
  },
  "[json]": {
    "editor.defaultFormatter": "biomejs.biome"
  }
}
```

## Disable Conflicting Extensions

When using Biome, disable conflicting extensions:

```json
// .vscode/settings.json
{
  "prettier.enable": false,
  "eslint.enable": false
}
```

## Recommended Extensions

```json
// .vscode/extensions.json
{
  "recommendations": [
    "biomejs.biome"
  ],
  "unwantedRecommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint"
  ]
}
```
