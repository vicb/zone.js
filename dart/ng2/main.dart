import 'vm_turn_zone.dart';
import 'dart:async';

void main() {
  var zone = new VmTurnZone(enableLongStackTrace: false);
  zone.initCallbacks(
    onTurnStart: () { print('>>> Turn start'); },
    onTurnDone: () { print('<<< Turn done'); }
  );

  multipleThen(zone);
}

/////////////////////////////////////////////// OK

// >>> Turn start
// inside
// <<< Turn done
nestedTasks(VmTurnZone zone) {
  zone.run(() {
    zone.run(() {
      print('inside');
    });
  });
}

/////////////////////////////////////////////// KO

//>>> Turn start
//+addMicrotask
//-addMicrotask
//<<< Turn done             <- bad done/start ?
//>>> Turn start
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
//<<< Turn done           <- bad done/start ?
//>>> Turn start
//then 1.1 (resolved)
//then 1.2 (resolved)
//<<< Turn done           <- bad done/start ?
//>>> Turn start
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

// TODO

// - chained then
// - completer
// - completer complete & then in different zones
// - then in inner zone, complete in outer zone
// - nested zone (ie runZoned)
