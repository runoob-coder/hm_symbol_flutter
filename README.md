# HarmonyOS Symbol

English | [简体中文](https://github.com/runoob-coder/hm_symbol_flutter/blob/master/README_CN.md)

[![pub package](https://img.shields.io/pub/v/hm_symbol.svg)](https://pub.dev/packages/hm_symbol)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![web demo](https://img.shields.io/badge/web%20demo-online-brightgreen.svg)](https://runoob-coder.github.io/hm_symbol_flutter/)

A Flutter icon library for [HarmonyOS Symbol](https://developer.huawei.com/consumer/cn/design/harmonyos-symbol/) — **3,844 icons** shipped as a single variable font.

<div align="center">
  <a href="https://runoob-coder.github.io/hm_symbol_flutter/" target="_blank" rel="noopener">
    <img src="https://raw.githubusercontent.com/runoob-coder/hm_symbol_flutter/master/icons.png" width="520" alt="HarmonyOS Symbol icons" />
  </a>
</div>

HarmonyOS Symbol is an important evolution of the HarmonyOS system icon design. It relies on
simplified shapes and intuitive semantics so that every glyph is easy to recognize, while adding a
younger, fresher touch to the overall visual style.

Because HarmonyOS Symbol **is a font**, it pairs seamlessly with system text: icons inherit their
size and color from `IconTheme`, align with text like any other character, and cost nothing to add
to an existing app. The font is also a *variable* font, so a single asset adapts its weight to the
surrounding text — no per-density icons, no extra files to bundle.

## ✨ Features

- 🎨 **3,844 icons** covering the complete HarmonyOS Symbol set.
- 🎚️ **Variable font**: continuous weight control, no duplicate glyph variants to maintain.
- 🔍 **Searchable**: every name is exposed at runtime through `harmonySymbolCatalog`.

## 🌐 Live demo

A searchable gallery runs on the web, no install required:

<https://runoob-coder.github.io/hm_symbol_flutter/>

It is the `example/` app of this repository, deployed to GitHub Pages on every push to `master`.

## 📦 Install

```console
flutter pub add hm_symbol
```

Then:

```dart
import 'package:hm_symbol/hm_symbol.dart';
```

## 🚀 Usage

Use it with the [Icon](https://api.flutter.dev/flutter/widgets/Icon-class.html) class. Every icon is
identified by its name, as listed in the [web gallery](https://runoob-coder.github.io/hm_symbol_flutter/):

```dart
Icon(HarmonySymbols.HarmonyOS);
```

Icons behave like text, so they can be styled from a single place:

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

### 🎚️ Variable font: size and weight

The font exposes a continuous weight axis, so icons can follow the typographic hierarchy:

```dart
Icon(HarmonySymbols.wifi, size: 32, weight: 600);
Icon(HarmonySymbols.wifi, size: 32, weight: 200);
```

## 🔍 Searching icons at runtime

`harmonySymbolCatalog` maps every symbol name to its `IconData`, which is all you need to build an
icon picker, a gallery or a search field:

```dart
final results = harmonySymbolCatalog.entries
    .where((entry) => entry.key.contains('wifi'))
    .toList();

for (final entry in results) {
  debugPrint('${entry.key} -> ${entry.value.codePoint}');
}
```

## 📱 Example app

```console
cd example
flutter pub get

flutter run -d chrome   # web
flutter run             # any attached device or desktop target
```

The gallery features keyword search, outline/fill category filters, adjustable grid size,
light/dark themes, and a detail sheet with copy-to-clipboard snippets.

## 🛠️ Building the web version

```console
cd example
flutter build web --release --base-href "/hm_symbol_flutter/"
```

The generated site lands in `example/build/web` and can be served by any static host. Pushing to
`master` triggers `.github/workflows/deploy_web.yml`, which publishes it to GitHub Pages — set your
own repository name in `--base-href` if you fork it.

## 🔁 Regenerating the bindings

`lib/src/*.g.dart` is generated from `tool/HMSymbol.nam` (a `codepoint name` table):

```console
dart run tool/generate.dart
```

## 📐 Design guides & resources

- <https://developer.huawei.com/consumer/cn/doc/design-guides/system-icons-0000001929854962>
- <https://docs.openharmony.cn/pages/v6.0/zh-cn/design/ux-design/visual-icons.md>
- <https://gitee.com/openharmony/docs/blob/master/zh-cn/design/ux-design/figures/OpenHarmony_Icons.zip>

## 📄 License

[MIT](./LICENSE) © noob-coder

The HarmonyOS Symbol font itself is owned by Huawei and is distributed here for convenience only.
Please follow the official guidelines linked above.

## 💛 Support

If `hm_symbol` helps you build better UIs, please consider supporting it.
It only takes a few seconds and helps other Flutter developers discover the library.

- ⭐ [Star on GitHub](https://github.com/runoob-coder/hm_symbol_flutter)
- 👍 [Like on pub.dev](https://pub.dev/packages/hm_symbol)

## [☕️ Buy Me a Coffee](https://www.noob-coder.com/buy-me-a-coffee)

|                                                                                   Buy Me a Coffee                                                                                   |                                                                                    Donate with PayPal                                                                                     |
|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| <a href="https://ko-fi.com/noob_coder" target="_blank"><img src="https://github.com/runoob-coder/runoob-coder/raw/main/public/kofi6.webp" alt="Buy Me a Coffee at ko-fi.com" /></a> | <a href="https://paypal.me/runoobcoder" target="_blank"><img src="https://github.com/runoob-coder/runoob-coder/raw/main/public/paypal-donate-button.avif" alt="Donate with PayPal" /></a> |
