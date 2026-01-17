import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

const fontFamily = 'HM Symbol';
const fontPackage = 'hm_symbol';

const url = '';

void main() {
  List<List<String>> cmap = File('./tool/HMSymbol.nam')
      .readAsStringSync()
      .split('\n')
      .map((line) => line.trim()) // 去除每行首尾空白
      .where((line) => line.isNotEmpty) // 过滤空行
      .map((line) => line.split(' ')) // 按单个空格分割
      .toList();

  generate(cmap);
}

const header =
    '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// 
// **************************************************************************
// $fontPackage
// **************************************************************************
//
''';

void generate(List<List<String>> icons) {
  final library = LibraryBuilder()
    ..directives.add(Directive.import('package:flutter/widgets.dart'))
    ..body
    ..comments.add(header)
    ..body.addAll([
      (ClassBuilder()
            ..docs.addAll([
              '/// ',
              '/// Use with the [Icon] class to show specific icons. Icons are identified by their name as listed below, e.g. ',
              '/// [HarmonySymbols.HarmonyOS_Next].',
              '/// ',
            ])
            ..annotations.add(refer('staticIconProvider'))
            ..name = 'HarmonySymbols'
            ..abstract = true
            ..modifier = ClassModifier.final$
            ..fields.addAll([
              (FieldBuilder()
                    ..static = true
                    ..modifier = FieldModifier.constant
                    ..name = 'iconFont'
                    ..assignment = literalString(fontFamily).code)
                  .build(),

              (FieldBuilder()
                    ..static = true
                    ..modifier = FieldModifier.constant
                    ..name = 'iconFontPackage'
                    ..assignment = literalString(fontPackage).code)
                  .build(),

              for (final icon in icons)
                (FieldBuilder()
                      ..docs.addAll([
                        '/// HarmonyOS Symbol named "${icon[1]}". ',
                      ])
                      ..static = true
                      ..modifier = FieldModifier.constant
                      ..type
                      ..name = icon[1]
                      ..assignment = refer('IconData')
                          .newInstance(
                            [literalNum(int.parse(icon[0]))],
                            {
                              'fontFamily': refer('iconFont'),
                              'fontPackage': refer('iconFontPackage'),
                            },
                          )
                          .code)
                    .build(),
            ]))
          .build(),
    ]);

  final code =
      DartFormatter(
        pageWidth: 120,
        languageVersion: DartFormatter.latestLanguageVersion,
      ).format(
        DartEmitter(
          orderDirectives: true,
          useNullSafetySyntax: true,
        ).visitLibrary(library.build()).toString(),
      );

  File('./lib/src/assets.g.dart').writeAsStringSync(code);
}
