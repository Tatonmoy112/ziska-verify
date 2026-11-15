import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Waits until events stop for [duration], then handles only the last one,
/// cancelling any earlier handler still running (final.md Section 8.3:
/// "debounce 400 ms + restartable").
EventTransformer<E> debounceRestartable<E>(Duration duration) =>
    (events, mapper) =>
        restartable<E>().call(events.transform(_Debounce(duration)), mapper);

class _Debounce<E> extends StreamTransformerBase<E, E> {
  const _Debounce(this.duration);

  final Duration duration;

  @override
  Stream<E> bind(Stream<E> stream) {
    late StreamController<E> controller;
    StreamSubscription<E>? subscription;
    Timer? timer;
    controller = StreamController<E>(
      sync: true,
      onListen: () {
        subscription = stream.listen(
          (event) {
            timer?.cancel();
            timer = Timer(duration, () => controller.add(event));
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            unawaited(controller.close());
          },
        );
      },
      onCancel: () {
        timer?.cancel();
        return subscription?.cancel();
      },
    );
    return controller.stream;
  }
}
