/*
 * check that document.registerElement(name, { prototype: proto });
 * is properly patched
 */

'use strict';

describe('document.registerElement', ifEnvSupports(registerElement, function () {

  // register a custom element for each callback
  var callbackNames = [
    'created',
    'attached',
    'detached',
    'attributeChanged'
  ];

  var callbacks = {};

  var outerZone = zone;

  var customElements;

  zone.fork().run(function () {
    customElements = callbackNames.map(function (callbackName) {
      var fullCallbackName = callbackName + 'Callback';
      var proto = Object.create(HTMLElement.prototype);
      proto[fullCallbackName] = function (arg) {
        callbacks[callbackName](arg);
      };
      return document.registerElement('x-' + callbackName.toLowerCase(), {
        prototype: proto
      });
    });
  });


  it('should work with createdCallback', function (done) {
    callbacks.created = function () {
      expect(zone.parent).toBe(outerZone);
      done();
    };
    document.createElement('x-created');
  });


  it('should work with attachedCallback', function (done) {
    callbacks.attached = function () {
      expect(zone.parent).toBe(outerZone);
      done();
    };
    var elt = document.createElement('x-attached');
    document.body.appendChild(elt);
    document.body.removeChild(elt);
  });


  it('should work with detachedCallback', function (done) {
    callbacks.detached = function () {
      expect(zone.parent).toBe(outerZone);
      done();
    };
    var elt = document.createElement('x-detached');
    document.body.appendChild(elt);
    document.body.removeChild(elt);
  });


  it('should work with attributeChanged', function (done) {
    callbacks.attributeChanged = function () {
      expect(zone.parent).toBe(outerZone);
      done();
    };
    var elt = document.createElement('x-attributechanged');
    elt.id = 'bar';
  });


  it('should work with non-writable, non-configurable prototypes created with defineProperty', function (done) {
    var proto = Object.create(HTMLElement.prototype);
    Object.defineProperty(proto, 'createdCallback', {
      writeable: false,
      configurable: false,
      value: checkZone
    });
    document.registerElement('x-prop-desc', {
      prototype: proto
    });
    var elt = document.createElement('x-prop-desc');

    function checkZone() {
      expect(zone.parent).toBe(outerZone);
      done();
    }
  });


  it('should work with non-writable, non-configurable prototypes created with defineProperties', function (done) {
    var proto = Object.create(HTMLElement.prototype);
    Object.defineProperties(proto, {
      createdCallback: {
        writeable: false,
        configurable: false,
        value: checkZone
      }
    });
    document.registerElement('x-props-desc', {
      prototype: proto
    });
    var elt = document.createElement('x-props-desc');

    function checkZone() {
      expect(zone.parent).toBe(outerZone);
      done();
    }
  });

}));

function registerElement() {
  return ('registerElement' in document);
}
registerElement.message = 'document.registerElement';
