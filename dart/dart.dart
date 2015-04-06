import 'dart:async';

var logs = [];
var p1, p2, c;
var nextZoneId = 3;
var nestedCount = 0;

function pprint(msg) {
  var indent = '   ' * nestedCount;
  print('$indent$msg');

}


dynamic onRun(Zone self, ZoneDelegate parent, Zone zone, fn()) {
  pprint('[${nestedCount}]beforeTask ${self[#id]} ${zone[#id]}');
  nestedCount++;
  parent.run(zone, fn);
  nestedCount--;
  pprint('[${nestedCount}]afterTask  ${self[#id]} ${zone[#id]}');
}

void func() {
  var mainId = Zone.current[#id];

  pprint('Main is executed in zone $mainId');

  // Future.value() -> resolves in a micro task
  p2 = new Future.value('resolved');

  // called when p2 completes (from a micro task)
  p2.then((_) {
      pprint('utask($_) #1 scheduled in $mainId executed in ${Zone.current[#id]}');
      return _;
    })
    .then((_) {
      pprint('utask($_) #2 scheduled in $mainId executed in ${Zone.current[#id]}');
    })
  ;

  // Future.value() -> resolves in a micro task
  new Future.value('resolved //').then((_) {
    pprint('utask($_) #1b scheduled in $mainId executed in ${Zone.current[#id]}');
    return _;
  });

  c = new Completer();

  p1 = c.future;

  p1.then((_) {
    pprint('uTask($_) #3 scheduled in $mainId executed in ${Zone.current[#id]}');
  });

  pprint('forking the zone');
  var forkZone = Zone.current.fork(
      zoneValues: {#id: nextZoneId++},
      specification: new ZoneSpecification(run: onRun)
  );

  forkZone.run(forkFunc);

  p2.then((_) {
    pprint('utask($_) #7 scheduled in $mainId executed in ${Zone.current[#id]}');
  });
}

void forkFunc() {
  var forkId = Zone.current[#id];

  pprint('fork is executed in zone $forkId');

  p1.then((_) {
    pprint('uTask($_) #4 scheduled in $forkId executed in ${Zone.current[#id]}');
  });

  p2.then((_) {
    pprint('uTask($_) #5 scheduled in $forkId executed in ${Zone.current[#id]}');
  });

  c.complete('complete in fork');

  new Future.value('resolved in fork').then((_) {
    pprint('uTask($_) #6 scheduled in $forkId executed in ${Zone.current[#id]}');
  });

}


void main() {

  // new Future() -> enqueue a macro task (event loop)
  new Future(() {
    pprint('!!! process event loop');
    var zone = Zone.current.fork(
        zoneValues: {#id: nextZoneId++},
        specification: new ZoneSpecification(run: onRun)
    );

    zone.run(func);
  });

  // new Future() -> enqueue a macro task (event loop)
  new Future(() {
    pprint('!!! process event loop');
  });

}
