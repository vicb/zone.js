import 'zone.dart';
import 'dart:async';

void main() {
  var zone = new VmTurnZone();
  zone.onTurnStart =  () { print('>>> Turn start'); };
  zone.onTurnDone = () { print('<<< Turn done'); };

  completeinOuterZone(zone);
}

/////////////////////////////////////////////// OK

//>>> Turn start
//inside
//<<< Turn done
nestedTasks(VmTurnZone zone) {
  zone.run(() {
    zone.run(() {
      print('inside');
    });
  });
}

//>>> Turn start
//+addMicrotask
//-addMicrotask
//microtask
//<<< Turn done
addMicrotask(VmTurnZone zone) {
  zone.run(() {
    print('+addMicrotask');
    scheduleMicrotask(() {
      print('microtask');
    });
    print('-addMicrotask');
  });
}

//>>> Turn start
//+mulitpleThen
//-mulitpleThen
//then 1.1 (resolved)
//then 1.2 (resolved)
//then 2.1 (resolved)
//then 2.2 (resolved)
//<<< Turn done
multipleThen(VmTurnZone zone) {
  zone.run(() {
    print('+mulitpleThen');
    var future1 = new Future.value('resolved');
    var future2 = new Future.value('resolved');
    future1.then((_) { print('then 1.1 ($_)');});
    future1.then((_) { print('then 1.2 ($_)');});
    future2.then((_) { print('then 2.1 ($_)');});
    future2.then((_) { print('then 2.2 ($_)');});
    print('-mulitpleThen');
  });
}

//+completer
//>>> Turn start
//+completer inner
//-completer inner
//<<< Turn done
//-completer
//>>> Turn start
//completer (resolved)
//<<< Turn done
completer(VmTurnZone zone) {
  print('+completer');
  Completer c = new Completer();
  zone.run(() {
    print('+completer inner');
    c.future.then((_) { print('completer inner ($_)'); });
    print('-completer inner');
  });
  c.complete('resolved');
  print('-completer');
}

//>>> Turn start
//+completeOutside
//outside
//-completeOutside
//completer inner (from outside)
//<<< Turn done
completeOutside(VmTurnZone zone) {
  zone.run(() {
    print('+completeOutside');
    Completer c = new Completer();
    c.future.then((_) { print('completer inner ($_)'); });
    zone.runOutsideAngular(() {
      print('outside');
      c.complete('from outside');
    });
    print('-completeOutside');
  });
}

//>>> Turn start
//+nestedZones
//+runZoned
//-runZoned
//-nestedZones
//outter zone (from inner)
//inner zone (from inner)
//<<< Turn done
nestedZones(VmTurnZone zone) {
  zone.run(() {
    print('+nestedZones');
    Completer c = new Completer();
    c.future.then((_) { print('outter zone ($_)'); });
    runZoned(() {
      print('+runZoned');
      c.future.then((_) { print('inner zone ($_)'); });
      c.complete('from inner');
      print('-runZoned');
    });

    print('-nestedZones');
  });
}

//>>> Turn start
//+Outside
//outside
//-Outside
//<<< Turn done
//outside zone
outside(VmTurnZone zone) {
  zone.run(() {
    print('+Outside');
    zone.runOutsideAngular(() {
      print('outside');
      // new Future(f) => f on the event loop
      new Future(() {
        // this should execute in the context of the outside zone
        // and should not trigger the change detection
        var f = new Future.value('');
        f.then((_) { print('outside zone'); });
      });
    });
    print('-Outside');
  });
}

//+completeinOuterZone
//+[_onRunBase]
//>>> Turn start
//<<< Turn done
//-[_onRunBase]
//-completeinOuterZone
//+[_onRunBase]
//>>> Turn start
//mtask
//<<< Turn done
//-[_onRunBase]
completeinOuterZone(VmTurnZone zone) {
  print('+completeinOuterZone');
  var c = new Completer();
  zone.run(() {
    // With Dart, no microtask is scheduled, only RunUnary
    c.future.then((_) { print('mtask'); });
  });
  c.complete('');
  print('-completeinOuterZone');
}


/////////////////////////////////////////////// KO

//>>> Turn start
//+Outside
//outside
//-Outside
//inside
//<<< Turn done
//event loop
//>>> Turn start   <- should not trigger a turn
//outside
//<<< Turn done
outside2(VmTurnZone zone) {
  zone.run(() {
    print('+Outside');
    var f = new Future.value('');
    zone.runOutsideAngular(() {
      print('outside');
      // new Future(f) => f on the event loop
      new Future(() {
        print('event loop');
        // this should execute in the context of the outside zone
        // and should not trigger the change detection
        f.then((_) { print('outside'); });
      });
    });
    f.then((_) { print('inside'); });
    print('-Outside');
  });
}


// TODO

// - chained then
// - completer
// - completer complete & then in different zones
// - then in inner zone, complete in outer zone
// - nested zone (ie runZoned)
