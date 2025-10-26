import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterExtension on WidgetTester {
  Future<void> renderWidgetWithBloc<TBloc extends BlocBase<dynamic>>({
    required Widget widget,
    required TBloc bloc,
  }) async {
    await pumpWidget(
      BlocProvider<TBloc>.value(
        value: bloc,
        child: MaterialApp(home: widget),
      ),
    );
    await pumpAndSettle();
  }
}
