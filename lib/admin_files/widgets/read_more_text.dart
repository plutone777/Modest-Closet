import 'package:flutter/material.dart';

class ReadMoreText extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const ReadMoreText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    const readMore = '... (Read more...)';

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: text, style: style);
        final tp = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);

        // If the full text fits, just show it
        if (!tp.didExceedMaxLines) {
          return Text(text, style: style, maxLines: maxLines, overflow: TextOverflow.clip);
        }

        // Find cutoff for first (maxLines-1) lines
        int cutoff = text.length;
        for (int i = text.length; i > 0; i--) {
          final testTp = TextPainter(
            text: TextSpan(text: text.substring(0, i), style: style),
            maxLines: maxLines - 1,
            textDirection: TextDirection.ltr,
          );
          testTp.layout(maxWidth: constraints.maxWidth);
          if (!testTp.didExceedMaxLines) {
            cutoff = i;
            break;
          }
        }
        final firstPart = text.substring(0, cutoff).trimRight();

        // Show first (maxLines-1) lines + a last pink line
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              firstPart,
              style: style,
              maxLines: maxLines - 1,
              overflow: TextOverflow.clip,
            ),
            Text(
              readMore,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
