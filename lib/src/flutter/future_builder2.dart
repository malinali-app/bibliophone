import 'package:flutter/material.dart';

/// Wrap builder to report errors
class FutureBuilder2<T> extends FutureBuilder<T> {
  FutureBuilder2({
    super.key,
    super.future,
    super.initialData,
    required AsyncWidgetBuilder<T> builder,
  }) : super(builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          if (snapshot.hasError) {
            FlutterError.reportError(FlutterErrorDetails(
                exception: snapshot.error!, stack: snapshot.stackTrace));
          }
          return builder(context, snapshot);
        });
}

class ColoredBoxProgress {
  static const greyWithCircularProgressIndic = ColoredBox(
    color: Colors.grey,
    child: Center(child: CircularProgressIndicator()),
  );
}
