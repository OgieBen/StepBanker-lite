import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final GestureTapCallback? onTap;
  final int currentStepsForTheDay;

  const RoundedButton(
      {Key? key, required this.onTap, required this.currentStepsForTheDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(90),
      onTap: onTap,
      child: SizedBox(
        width: 180,
        height: 180,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(90)),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: Column(
                  children: [
                    const Spacer(),
                    Text("$currentStepsForTheDay"),
                    const Spacer(),
                    const Text("Steps"),
                    const Spacer()
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
