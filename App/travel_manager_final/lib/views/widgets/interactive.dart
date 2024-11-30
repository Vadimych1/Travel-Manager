// 28.03.2024 // interactive.dart // Interactive widgets

import "package:flutter/material.dart";

class Input extends StatefulWidget {
  const Input({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    required this.validator,
    required this.onChanged,
    required this.onValidChanged,
    this.bgColor = Colors.transparent,
    this.labelColor = const Color(0xFF686868),
    this.borderRadius = 10.0,
    this.initialValid = false,
  });

  final TextEditingController controller;
  final String label;
  final String placeholder;
  final bool Function(String) validator;
  final void Function(String) onChanged;
  final void Function(bool) onValidChanged;

  final Color bgColor;
  final Color labelColor;
  final double borderRadius;
  final bool initialValid;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  bool valid = false;

  @override
  void initState() {
    super.initState();
    valid = widget.initialValid;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.label.isNotEmpty
            ? Text(
                widget.label,
                style: TextStyle(
                  color: widget.labelColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              )
            : Container(),
        TextField(
          controller: widget.controller,
          onChanged: (s) {
            widget.onChanged(s);
            setState(() {
              var prevValid = valid;
              valid = widget.validator(s);

              if (prevValid != valid) {
                widget.onValidChanged(valid);
              }
            });
          },
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: const TextStyle(
              color: Color(0xFF686868),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 62, 90, 78),
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF659581),
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFFE74C3C),
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 182, 63, 50),
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            contentPadding: const EdgeInsets.only(left: 12),
            errorText: valid ? null : "",
            errorStyle: const TextStyle(fontSize: 0),
            fillColor: widget.bgColor,
            filled: true,
          ),
        ),
      ],
    );
  }
}

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
  });

  final String text;
  final void Function() onPressed;
  final bool enabled;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          widget.enabled ? const Color(0xFF659581) : Colors.white,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(
              color: widget.enabled
                  ? const Color(0xFF659581)
                  : const Color(0xFFCDCDCD),
            ),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 43, vertical: 11),
        ),
      ),
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.enabled
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF7B7B7B),
        ),
      ),
    );
  }
}

class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.onChanged,
    required this.code,
  });

  final void Function(bool) onChanged;
  final String code;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  Map<int, TextEditingController> controllers = {
    0: TextEditingController(),
    1: TextEditingController(),
    2: TextEditingController(),
    3: TextEditingController(),
  };

  List<String> code = ["", "", "", ""];
  bool valid = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            height: 60,
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              style: TextStyle(
                fontSize: 24,
                color: valid
                    ? const Color(0xFF000000)
                    : code.join().length == 4
                        ? const Color(0xFFE74C3C)
                        : const Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF000000),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE74C3C),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF000000),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF000000),
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 182, 63, 50),
                  ),
                ),
                errorText: valid
                    ? null
                    : code.join("").length == 4
                        ? ""
                        : null,
                errorStyle: const TextStyle(fontSize: 0),
              ),
              controller: controllers[i],
              onChanged: (s) {
                code[i] = s;

                if (s.isNotEmpty) {
                  controllers[i]!.text = s.characters.last;
                  if (i < 3) {
                    controllers[i + 1]!.text = "";
                    FocusScope.of(context).nextFocus();
                  }
                } else {
                  if (i > 0) {
                    FocusScope.of(context).previousFocus();
                  }
                }

                if (s.isNotEmpty) {
                  code[i] = s.characters.last;
                } else {
                  code[i] = "";
                }

                if (code.join("") == widget.code) {
                  setState(() {
                    valid = true;
                  });
                } else {
                  setState(() {
                    valid = false;
                  });
                }

                widget.onChanged(valid);
              },
            ),
          ),
      ],
    );
  }
}

class SideScrollerBlock extends StatefulWidget {
  const SideScrollerBlock({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  State<SideScrollerBlock> createState() => _SideScrollerBlockState();
}

class _SideScrollerBlockState extends State<SideScrollerBlock> {
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var ch in widget.children)
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: ch,
            ),
        ],
      ),
    );
  }
}

class DatePickerInput extends StatefulWidget {
  const DatePickerInput({
    super.key,
    required this.onChanged,
    required this.startDate,
    this.currentDate,
    this.text = "Выберите дату",
    this.bgColor = const Color(0xFFFFFFFF),
    this.canSelect = true,
  });

  final String text;
  final void Function(DateTime?) onChanged;
  final Color bgColor;
  final DateTime startDate;
  final DateTime? currentDate;
  final bool canSelect;

  @override
  State<DatePickerInput> createState() => _DatePickerInputState();
}

class _DatePickerInputState extends State<DatePickerInput> {
  DateTime? date;

  @override
  Widget build(BuildContext context) {
    date = widget.currentDate;
    return InkWell(
      onTap: () async {
        if (!widget.canSelect) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Заполните предыдущие поля"),
            ),
          );
          return;
        }
        date = await showDatePicker(
          context: context,
          helpText: "Выберите дату",
          cancelText: "Отмена",
          confirmText: "Выбрать",
          initialDate: widget.currentDate ??
              widget.startDate.add(const Duration(days: 1)),
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          firstDate: widget.startDate,
          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
        );
        setState(() {});
        widget.onChanged(date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(
            color: date == null
                ? const Color(0xFFE74C3C)
                : const Color.fromARGB(255, 62, 90, 78),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 12, top: 15, bottom: 12),
        child: date == null
            ? Text(widget.text)
            : Text("${date!.day}/${date!.month}/${date!.year}"),
      ),
    );
  }
}

class ActivitiesSelectPreset extends StatefulWidget {
  const ActivitiesSelectPreset({
    super.key,
    required this.onChanged,
    required this.name,
    required this.icon,
    required this.callbackQuery,
    required this.type,
  });

  final String name;
  final Widget icon;
  final void Function(String, String) onChanged;
  final String callbackQuery;
  final String type;

  @override
  State<ActivitiesSelectPreset> createState() => _ActivitiesSelectPresetState();
}

class _ActivitiesSelectPresetState extends State<ActivitiesSelectPreset> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onChanged(widget.callbackQuery, widget.type);
      },
      splashFactory: NoSplash.splashFactory,
      child: Container(
        width: (MediaQuery.of(context).size.width - 50) / 2,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0x33689985),
          borderRadius: BorderRadius.circular(13),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.icon,
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 14.3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
