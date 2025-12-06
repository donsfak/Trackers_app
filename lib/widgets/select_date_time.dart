import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackers_app/providers/providers.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/widgets/common_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SelectDateTime extends ConsumerWidget {
  const SelectDateTime({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);
    final time = ref.watch(timeProvider);

    return Row(
      children: [
        Expanded(
          child: CommonTextField(
              title: 'Date',
              hintText: DateFormat.yMMMd().format(date),
              readOnly: true,
              suffixIcon: IconButton(
                  onPressed: () => Helpers.selectDate(context, ref),
                  icon: FaIcon(FontAwesomeIcons.calendar))),
        ),
        SizedBox(width: 10),
        Expanded(
          child: CommonTextField(
              title: 'Time',
              hintText: Helpers.timeToString(time),
              readOnly: true,
              suffixIcon: IconButton(
                  onPressed: () => _selectTime(context, ref),
                  icon: const FaIcon(FontAwesomeIcons.clock))),
        ),
      ],
    );
  }

  void _selectTime(BuildContext context, WidgetRef ref) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      ref.read(timeProvider.notifier).state = pickedTime;
    }
  }
}
