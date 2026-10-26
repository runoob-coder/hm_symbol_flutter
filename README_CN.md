# HarmonyOS Symbol

[English](./README.md) | 简体中文

[![Pub Version](https://img.shields.io/pub/v/hm_symbol.svg)](https://pub.dev/packages/hm_symbol)
[![API Reference](https://img.shields.io/badge/API-Reference-0175C2.svg)](https://pub-web.flutter-io.cn/documentation/hm_symbol/latest/)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/runoob-coder/hm_symbol_flutter)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Flutter Demo](https://img.shields.io/badge/demo-Flutter-brightgreen.svg)](https://runoob-coder.github.io/hm_symbol_flutter/)
[![CI](https://img.shields.io/github/actions/workflow/status/runoob-coder/hm_symbol_flutter/deploy_web.yml?label=CI)](https://github.com/runoob-coder/hm_symbol_flutter/actions/workflows/deploy_web.yml)
[![GitHub stars](https://img.shields.io/github/stars/runoob-coder/hm_symbol_flutter.svg?style=social)](https://github.com/runoob-coder/hm_symbol_flutter)

面向 Flutter 的 [HarmonyOS Symbol](https://developer.huawei.com/consumer/cn/design/harmonyos-symbol/) 图标库。

<div align="center">
  <a href="https://runoob-coder.github.io/hm_symbol_flutter/" target="_blank" rel="noopener">
    <img src="https://raw.githubusercontent.com/runoob-coder/hm_symbol_flutter/master/icons.png" width="520" alt="HarmonyOS Symbol icons" />
  </a>
</div>

[HarmonyOS Symbol](https://developer.huawei.com/consumer/cn/design/harmonyos-symbol/) 代表了 HarmonyOS 系统图标设计的一次重要演进。

它通过简化的图形和直观的语义表达，不仅易于识别，同时融入了更多年轻化的设计理念，使得整体的视觉风格更加年轻和时尚。

同时 HarmonyOS Symbol 还具备了字体属性，使其能够与系统字体无缝对接，确保了文本与图标的排版一致性。

此外，它能够根据文本的粗细变化进行智能适配，确保了在不同文本粗细下，图标能够灵活适应，保持视觉的连贯性和一致性。

## ✨ 特性

- 🎨 **3844 个图标**，覆盖完整的 HarmonyOS Symbol 图标集；
- 🎚️ **可变字体**：字重连续可调，无需维护多套图标资源；
- 🔍 **支持搜索**：通过 `harmonySymbolCatalog` 在运行时获取全部图标名称与 `IconData` 的映射；

## 🌐 在线网页版

无需安装，直接在浏览器中浏览并搜索全部图标：

<https://runoob-coder.github.io/hm_symbol_flutter/>

网页版本仓库中的 `example/` 应用，`master` 分支每次推送都会自动部署到 GitHub Pages。

## 📦 安装

```console
flutter pub add hm_symbol
```

然后导入：

```dart
import 'package:hm_symbol/hm_symbol.dart';
```

## 🚀 使用方式

配合 [Icon](https://api.flutter.dev/flutter/widgets/Icon-class.html) 使用即可，图标名称可在
[在线网页版](https://runoob-coder.github.io/hm_symbol_flutter/) 中搜索查看：

```dart
Icon(HarmonySymbols.HarmonyOS);
```

图标具备字体属性，因此可以在一处统一设置样式：

```dart
IconTheme(
  data: IconThemeData(size: 24, color: Theme.of(context).colorScheme.primary),
  child: Row(
    children: const [
      Icon(HarmonySymbols.wifi),
      Icon(HarmonySymbols.lock),
      Icon(HarmonySymbols.star_fill),
    ],
  ),
);
```

### 🎚️ 可变字体：大小与字重

字体提供了连续的字重轴，图标可以跟随文本的层级自由调整：

```dart
Icon(HarmonySymbols.wifi, size: 32, weight: 600);
Icon(HarmonySymbols.wifi, size: 32, weight: 200);
```

## 🔍 运行时搜索图标

`harmonySymbolCatalog` 维护了图标名称到 `IconData` 的映射，据此可以轻松实现图标选择器、图标库或搜索功能：

```dart
final results = harmonySymbolCatalog.entries
    .where((entry) => entry.key.contains('wifi'))
    .toList();

for (final entry in results) {
  debugPrint('${entry.key} -> ${entry.value.codePoint}');
}
```

## 📱 示例项目

```console
cd example
flutter pub get

flutter run -d chrome   # 运行网页版
flutter run             # 运行到已连接的设备或桌面端
```

示例应用提供关键词搜索、描边/填充分类筛选、网格大小调节、深浅色主题切换，以及支持一键复制代码的详情面板。

## 🛠️ 构建网页版

```console
cd example
flutter build web --release --base-href "/hm_symbol_flutter/"
```

构建产物位于 `example/build/web`，可直接部署到任意静态服务器。向 `master` 推送代码时，
`.github/workflows/deploy_web.yml` 会自动发布到 GitHub Pages；Fork 后请将 `--base-href` 替换为自己的仓库名。

## 🔁 重新生成代码

`lib/src/*.g.dart` 由 `tool/HMSymbol.nam`（`codepoint 名称` 对照表）生成：

```console
dart run tool/generate.dart
```

## 📐 设计规范与资源

- <https://developer.huawei.com/consumer/cn/doc/design-guides/system-icons-0000001929854962>
- <https://docs.openharmony.cn/pages/v6.0/zh-cn/design/ux-design/visual-icons.md>
- <https://gitee.com/openharmony/docs/blob/master/zh-cn/design/ux-design/figures/OpenHarmony_Icons.zip>

## 📄 开源协议

[MIT](./LICENSE) © noob-coder

HarmonyOS Symbol 字体本身的著作权归华为所有，此处仅为方便使用而随包分发，请遵循上述官方设计规范。

## 💛 支持

如果 `hm_symbol` 帮助了你，请考虑支持它，只需几秒即可帮助更多 Flutter 开发者发现此库。

- ⭐ [GitHub 上点星](https://github.com/runoob-coder/hm_symbol_flutter)
- 👍 [pub.dev 上点赞](https://pub.dev/packages/hm_symbol)

## [☕️ 请我喝奶茶](https://www.noob-coder.com/buy-me-a-coffee)

<table>
<thead>
<tr>
    <th style="text-align:center;">赞赏码 WeChat</th>
    <th style="text-align:center;">支付宝 Alipay</th>
</tr>
</thead>
<tbody>
<tr>
    <td width="50%"><img src="https://raw.githubusercontent.com/runoob-coder/runoob-coder/main/public/appreciate.avif" alt="赞赏码WeChat" /></td>
    <td width="50%"><img src="https://raw.githubusercontent.com/runoob-coder/runoob-coder/main/public/alipay.avif" alt="支付宝Alipay" /></td>
  </tr>
</tbody>
</table>