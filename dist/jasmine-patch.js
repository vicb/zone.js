(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var jasminePatch = require('../jasmine/patch');

jasminePatch.apply();

},{"../jasmine/patch":2}],2:[function(require,module,exports){
(function (global){
'use strict';
// Patch jasmine's it and fit functions so that the `done` callback always resets the zone
// to the jasmine zone, which should be the root zone. (angular/zone.js#91)

function apply() {
  if (!global.zone) {
    throw new Error('zone.js does not seem to be installed');
  }

  if (!global.zone.isRootZone()) {
    throw new Error('The jasmine patch should be called from the root zone');
  }

  var jasmineZone = global.zone;
  var originalIt = global.it;
  var originalFit = global.fit;

  global.it = function zoneResettingIt(description, specFn) {
    originalIt(description, function (done) {
      var jasmineThis = this;
      // Wrap the spec in a set timeout so that the microtasks queue is drained before the test runs.
      setTimeout(function() {
        jasmineZone.run(specFn, jasmineThis, [done]);
        if (specFn.length == 0) {
          // Need to manually call done() when the test is sync due to the setTimeout
          done();
        }
      });
    });
  };

  global.fit = function zoneResettingFit(description, specFn) {
    originalFit(description, function (done) {
      var jasmineThis = this;
      // Wrap the spec in a set timeout so that the microtasks queue is drained before the test runs.
      setTimeout(function() {
        jasmineZone.run(specFn, jasmineThis, [done]);
        if (specFn.length == 0) {
          // Need to manually call done() when the test is sync due to the setTimeout
          done();
        }
      });
    });
  };
}

if (global.jasmine) {
  module.exports = {
    apply: apply
  };
} else {
  module.exports = {
    apply: function() { }
  };
}

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}]},{},[1]);
