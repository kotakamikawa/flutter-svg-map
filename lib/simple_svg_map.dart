import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart';

class JapanColoredMap extends StatelessWidget {
  final Map<String, Color> _prefectureColors;

  const JapanColoredMap(this._prefectureColors, {super.key});

  Future<String> _loadAndApplyColors() async {
    String asset =
        await rootBundle.loadString('images/Japan_template_large.svg');
    final document = XmlDocument.parse(asset);

    final rootElement = document.rootElement;
    final gElements = rootElement.findAllElements('g');

    for (var g in gElements) {
      final id = g.getAttribute('id');
      if (id != null) {
        final color = _prefectureColors[id] ?? Colors.white;
        final paths = g.findAllElements('path');
        for (var path in paths) {
          path.setAttribute('fill', colorToHex(color));
        }
      }
    }
    return document.toXmlString();
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadAndApplyColors(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SvgPicture.string(snapshot.data!);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
