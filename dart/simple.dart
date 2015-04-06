import 'dart:async';
import 'dart:mirrors';


var count = 0;
var depth = 0;

var parentZone, childZone;

test() {
  print('[+test]');
  new Future(() {
    print('before test macrotask');
  });

  runZoned(() {
    print('run zoned');
  });

  new Future(() {
    testInner();
  });

  new Future(() {
    print('after test macrotask');
  });
  print('[-test]');
}



testInner() {
  print('+[testInner]');
  new Future.value('zone').then((_) { print('zone (before)'); });
  scheduleMicrotask(() { print('zone microtask (before)'); });

  runZoned(() {
    print('++inner');
    new Future.value('zone').then((_) { print('inner zone'); });
    scheduleMicrotask(() { print('inner microtask'); });
    print('--inner');
  });

  new Future.value('zone').then((_) { print('zone (after)'); });
  scheduleMicrotask(() { print('zone microtask (after)'); });
  print('-[testInner]');
}

_run(Zone self, ZoneDelegate parent, Zone zone, fn()) {

  if (count == 0 && depth == 0) {
    print ('### Start of turn ###');
  }

  print('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  print('+[_run] count=$count self=${zoneName(self)} zone=${zoneName(zone)} depth=$depth');
  print('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  var mirror = reflect(fn);
  print(mirror.function.source);
  print('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

  // Have to run in the zone, otherwise scheduleMicrotask is done on self
  print('+[parent.run]');
  depth++;
  parent.run(zone, fn);
  depth--;
  print('-[parent.run]');
  print('count=$count');
  if (count == 0 && depth == 0) {
    print ('### End of turn ###');
  }
  print('------------------------------------------------------------------------');
}

_schedule(Zone self, ZoneDelegate parent, Zone zone, fn()) {
  print('[_schedule]');
  count++;
  var cb = zone.registerCallback(fn);
  var microtask = () {
    print('+microtask $count');
    cb();
    count--;
    print('-microtask $count');
  };
  parent.scheduleMicrotask(zone, microtask);
}

var zoneSpec = new ZoneSpecification(
  run: _run,
  scheduleMicrotask: _schedule
);

void main() {

  parentZone = Zone.current;

  childZone = Zone.current.fork(specification: zoneSpec);

  childZone.run(test);

}

zoneName(zone) {
  if (zone == parentZone) return 'parent';
  if (zone == childZone) return 'child';

  return '?';
}




