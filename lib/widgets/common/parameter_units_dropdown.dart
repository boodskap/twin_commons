import 'package:flutter/material.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';

class ParameterUnitsDropdown extends StatefulWidget {
  /// Text editing controller
  final TextEditingController? controller;

  /// Function that handles the changes to the input
  final Function(String)? onChanged;

  /// Function that handles the submission of the input
  final Function(String)? onSubmitted;

  final String? label;

  const ParameterUnitsDropdown(
      {super.key,
      this.controller,
      this.onChanged,
      this.onSubmitted,
      this.label = 'Unit'});

  @override
  State<ParameterUnitsDropdown> createState() => _ParameterUnitsDropdownState();
}

class _ParameterUnitsDropdownState extends BaseState<ParameterUnitsDropdown> {
  final List<String> suggestions = [];

  @override
  Widget build(BuildContext context) {
    return EasyAutocomplete(
      suggestions: suggestions,
      controller: widget.controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.label,
      ),
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    suggestions.clear();
    await execute(() async {
      var res = await TwinnedSession.instance.twin
          .getParameterUnits(apikey: TwinnedSession.instance.authToken);
      if (validateResponse(res)) {
        suggestions.addAll(res.body!.entity!.units);
      }
    });
    refresh();
    loading = false;
  }

  @override
  void setup() {
    _load();
  }
}
