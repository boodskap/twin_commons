import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

typedef OnFontPicked = void Function(String font);
typedef OnFontSizePicked = void Function(double fontSize);
typedef OnFontColorPicked = void Function(int fontColor);

class FontSettingWidget extends StatefulWidget {
  final String title;
  String font;
  double fontSize;
  int fontColor;
  int bgColor;
  final OnFontPicked onFontPicked;
  final OnFontSizePicked onFontSizePicked;
  final OnFontColorPicked onFontColorPicked;
  final double minFontSize;
  final double maxFontSize;
  FontSettingWidget(
      {super.key,
      required this.title,
      required this.font,
      required this.fontSize,
      required this.fontColor,
      this.bgColor = 0,
      this.minFontSize = 4,
      this.maxFontSize = 100,
      required this.onFontPicked,
      required this.onFontSizePicked,
      required this.onFontColorPicked});

  @override
  State<FontSettingWidget> createState() => _FontSettingWidgetState();
}

class _FontSettingWidgetState extends State<FontSettingWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 150,
          child: Text(
            widget.font,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Tooltip(
          message: 'Change Font',
          child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Choose a Font"),
                      content: SizedBox(
                        height: 600,
                        width: 600,
                        child: FontPicker(
                          showFontVariants: false,
                          initialFontFamily: widget.font,
                          onFontChanged: (PickerFont font) {
                            widget.font = font.fontFamily;
                            widget.onFontPicked(widget.font);
                            setState(() {});
                          },
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.font_download_sharp)),
        ),
        Tooltip(
          message: 'Change Font Size',
          child: IconButton(
              onPressed: () {
                double fontSize = widget.fontSize;
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return SizedBox(
                        child: AlertDialog(
                          title: const Text('Font Size'),
                          content: SizedBox(
                            height: 150,
                            child: Column(
                              children: [
                                SpinBox(
                                  min: widget.minFontSize,
                                  max: widget.maxFontSize,
                                  value: fontSize,
                                  onSubmitted: (value) {
                                    setState(() {
                                      fontSize = value;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                      onPressed: () {
                                        widget.onFontSizePicked(fontSize);
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Select",
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Cancel",
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
              icon: const Icon(Icons.format_size)),
        ),
        Tooltip(
          message: 'Change Font Color',
          child: IconButton(
              onPressed: () {
                Color pickedColor = Color(widget.fontColor);
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text('Pick a Color'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              ColorPicker(
                                pickerColor: pickedColor,
                                enableAlpha: true,
                                displayThumbColor: true,
                                hexInputBar: true,
                                onColorChanged: (color) {
                                  pickedColor = color;
                                  widget.onFontColorPicked(pickedColor.value);
                                  setState(() {});
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        widget.fontColor = pickedColor.value;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Ok",
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Cancel",
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: const Icon(
                Icons.color_lens,
              )),
        ),
        Expanded(
          child: Container(
            color: Color(widget.bgColor),
            child: Text(
              'The quick brown fox jumps over the lazy dog',
              style: GoogleFonts.getFont(widget.font).copyWith(
                  color: Color(widget.fontColor),
                  fontSize: widget.fontSize,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    );
  }
}
