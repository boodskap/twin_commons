import 'package:flutter/material.dart';

typedef FilterValueChanged = void Function(
    String filter, int? beginStamp, int? endStamp);

class DateFilterDropdown extends StatefulWidget {
  final Color iconColor;
  final double maxWidth;
  final double minWidth;
  final double smFontSize;
  final double iconSize;
  final TextStyle dropDownTextStyle;
  final FilterValueChanged onChanged;
  final double responsiveWidth;
  const DateFilterDropdown({
    super.key,
    required this.onChanged,
    this.maxWidth = 450,
    this.minWidth = 480,
    this.iconColor = Colors.black,
    this.smFontSize = 11,
    this.iconSize = 18,
    this.dropDownTextStyle = const TextStyle(
      fontSize: 14,
    ),
    this.responsiveWidth = 380,
  });

  @override
  State<DateFilterDropdown> createState() => _DateFilterDropdownState();
}

class _DateFilterDropdownState extends State<DateFilterDropdown> {
  String selectedDateFilterDropdown = 'RECENT';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  List<String> dropdownItems = [
    'RECENT',
    'TODAY',
    'YESTERDAY',
    'THISWEEK',
    'LASTWEEK',
    'THISMONTH',
    'LASTMONTH',
    'THISQUARTER',
    'THISYEAR',
    'LASTYEAR',
    'RANGE',
  ];
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = widget.smFontSize;
    double adjustedIconSize = screenWidth < widget.responsiveWidth
        ? widget.iconSize * 0.75
        : widget.iconSize;
    return DropdownButton<String>(
      icon: Icon(Icons.filter_list,
          color: widget.iconColor, size: adjustedIconSize),
      items: dropdownItems.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value,
              style: screenWidth > widget.responsiveWidth
                  ? widget.dropDownTextStyle
                  : widget.dropDownTextStyle.copyWith(fontSize: fontSize)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedDateFilterDropdown = newValue!;
        });
        if (selectedDateFilterDropdown == 'RANGE') {
          _showDateRangePicker();
        }
        widget.onChanged(newValue ?? 'RECENT', startDate.millisecondsSinceEpoch,
            endDate.millisecondsSinceEpoch);
      },
      value: selectedDateFilterDropdown,
    );
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(
          start: startDate,
          end: endDate,
        ),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 450.0, maxHeight: 480),
                child: child,
              )
            ],
          );
        });

    if (picked != null &&
        picked != DateTimeRange(start: startDate, end: endDate)) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }
}
