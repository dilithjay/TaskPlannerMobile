import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/$assetName', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Navigation",
          body:
              "Press the General, Today or History tabs to navigate to the respective list of tasks.\n\n Press the Add button to add a new task.",
          image: _buildImage('navBar.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "General Tab",
          body:
              "The General tab contains all the scheduled tasks.\n\nTasks can be deleted by swiping right and tasks can be ended by swiping left.",
          image: _buildImage('generalTab.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Today Tab",
          body:
              "The Today tab contains all the scheduled tasks for today + all the daily tasks.\n\nFor daily tasks, the streak of how many days the task was completed is mentioned in the circle\n\nGeneral tasks cannot be deleted/ended from this tab.",
          image: _buildImage('todayTab.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "History Tab",
          body:
              "The History Tab contains all the ended tasks.\n\nEnded tasks can be deleted by swiping left.",
          image: _buildImage('historyTab.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Add Task Page",
          body:
              "Type the task on the Task textbox.\n\nSelect the 'Daily' checkbox to add a daily task.\n\nPress 'Select Date' to select a date for a general task",
          image: _buildImage('addTask.png'),
          decoration: pageDecoration,
        ),
        /*PageViewModel(
          title: "Thank you for installing Task Planner!",
          body: "",
          image: _buildImage('logo.png'),
          decoration: pageDecoration,
        ),*/
      ],
      onDone: () => moveToLastScreen(),
      onSkip: () => moveToLastScreen(), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
