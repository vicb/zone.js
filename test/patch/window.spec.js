'use strict';

describe('window', function() {
  var testZone = zone.fork();

  describe('url changes', function () {
    it('should allow listening to url changes via .onhashchange', function(done) {
      var hash = location.hash;

      testZone.run(function() {
        window.onhashchange = function() {
          window.onhashchange = null;
          location.hash = hash;
          expect(window.zone).toBeDirectChildOf(testZone);
          done();
        };
      });

      location.hash = 'test';
    });

    it('should allow listening to url changes via an event listener', function(done) {
      var hash = location.hash;

      var listener = function() {
        window.removeEventListener('hashchange', listener);
        location.hash = hash;
        expect(window.zone).toBeDirectChildOf(testZone);
        done();
      };

      testZone.run(function() {
        window.addEventListener('hashchange', listener);
      });

      location.hash = 'test';
    });
  });
});
