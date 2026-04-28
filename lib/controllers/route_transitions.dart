import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

class SlidePageRoute<T> extends CupertinoPageRoute<T> {
  SlidePageRoute({required Widget page}) : super(builder: (context) => page);
}


