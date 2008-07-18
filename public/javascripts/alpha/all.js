/*  Prototype JavaScript framework, version 1.6.0_pre1
 *  (c) 2005-2007 Sam Stephenson
 *
 *  Prototype is freely distributable under the terms of an MIT-style license.
 *  For details, see the Prototype web site: http://www.prototypejs.org/
 *
 *--------------------------------------------------------------------------*/

var Prototype = {
  Version: '1.6.0_pre1',

  Browser: {
    IE:     !!(window.attachEvent && !window.opera),
    Opera:  !!window.opera,
    WebKit: navigator.userAgent.indexOf('AppleWebKit/') > -1,
    Gecko:  navigator.userAgent.indexOf('Gecko') > -1 && navigator.userAgent.indexOf('KHTML') == -1,
    MobileSafari: !!navigator.userAgent.match(/iPhone.*Mobile.*Safari/)
  },

  BrowserFeatures: {
    XPath: !!document.evaluate,
    ElementExtensions: !!window.HTMLElement,
    SpecificElementExtensions:
      document.createElement('div').__proto__ !==
       document.createElement('form').__proto__
  },

  ScriptFragment: '<script[^>]*>([\\S\\s]*?)<\/script>',
  JSONFilter: /^\/\*-secure-([\s\S]*)\*\/\s*$/,

  emptyFunction: function() { },
  K: function(x) { return x }
};

if (Prototype.Browser.MobileSafari)
  Prototype.BrowserFeatures.SpecificElementExtensions = false;

var Class = {
  create: function() {
    return function() {
      this.initialize.apply(this, arguments);
    }
  }
}

var Abstract = new Object();

Object.extend = function(destination, source) {
  for (var property in source) {
    destination[property] = source[property];
  }
  return destination;
}

Object.extend(Object, {
  inspect: function(object) {
    try {
      if (object === undefined) return 'undefined';
      if (object === null) return 'null';
      return object.inspect ? object.inspect() : object.toString();
    } catch (e) {
      if (e instanceof RangeError) return '...';
      throw e;
    }
  },

  toJSON: function(object) {
    var type = typeof object;
    switch(type) {
      case 'undefined':
      case 'function':
      case 'unknown': return;
      case 'boolean': return object.toString();
    }
    if (object === null) return 'null';
    if (object.toJSON) return object.toJSON();
    if (Object.isElement(object)) return;
    var results = [];
    for (var property in object) {
      var value = Object.toJSON(object[property]);
      if (value !== undefined)
        results.push(property.toJSON() + ': ' + value);
    }
    return '{' + results.join(', ') + '}';
  },

  toHTML: function(object) {
    return object && object.toHTML ? object.toHTML() : String.interpret(object);
  },

  keys: function(object) {
    var keys = [];
    for (var property in object)
      keys.push(property);
    return keys;
  },

  values: function(object) {
    var values = [];
    for (var property in object)
      values.push(object[property]);
    return values;
  },

  clone: function(object) {
    return Object.extend({}, object);
  },

  isElement: function(object) {
    return object && object.nodeType == 1;
  },

  isArray: function(object) {
    return object && object.constructor === Array;
  }
});

Object.extend(Function.prototype, {
  bind: function() {
    if (arguments.length < 2 && arguments[0] === undefined) return this;
    var __method = this, args = $A(arguments), object = args.shift();
    return function() {
      return __method.apply(object, args.concat($A(arguments)));
    }
  },

  bindAsEventListener: function() {
    var __method = this, args = $A(arguments), object = args.shift();
    return function(event) {
      return __method.apply(object, [event || window.event].concat(args));
    }
  },

  curry: function() {
    if (!arguments.length) return this;
    var __method = this, args = $A(arguments);
    return function() {
      return __method.apply(this, args.concat($A(arguments)));
    }
  },

  delay: function() {
    var __method = this, args = $A(arguments), timeout = args.shift() * 1000;
    return window.setTimeout(function() {
      return __method.apply(__method, args);
    }, timeout);
  },

  wrap: function(wrapper) {
    var __method = this;
    return function() {
      return wrapper.apply(this, [__method.bind(this)].concat($A(arguments)));
    }
  },

  methodize: function() {
    if (this._methodized) return this._methodized;
    var __method = this;
    return this._methodized = function() {
      return __method.apply(null, [this].concat($A(arguments)));
    };
  }
});

Function.prototype.defer = Function.prototype.delay.curry(0.01);

Date.prototype.toJSON = function() {
  return '"' + this.getFullYear() + '-' +
    (this.getMonth() + 1).toPaddedString(2) + '-' +
    this.getDate().toPaddedString(2) + 'T' +
    this.getHours().toPaddedString(2) + ':' +
    this.getMinutes().toPaddedString(2) + ':' +
    this.getSeconds().toPaddedString(2) + '"';
};

var Try = {
  these: function() {
    var returnValue;

    for (var i = 0, length = arguments.length; i < length; i++) {
      var lambda = arguments[i];
      try {
        returnValue = lambda();
        break;
      } catch (e) {}
    }

    return returnValue;
  }
}

RegExp.prototype.match = RegExp.prototype.test;

/*--------------------------------------------------------------------------*/

var PeriodicalExecuter = Class.create();
PeriodicalExecuter.prototype = {
  initialize: function(callback, frequency) {
    this.callback = callback;
    this.frequency = frequency;
    this.currentlyExecuting = false;

    this.registerCallback();
  },

  registerCallback: function() {
    this.timer = setInterval(this.onTimerEvent.bind(this), this.frequency * 1000);
  },

  stop: function() {
    if (!this.timer) return;
    clearInterval(this.timer);
    this.timer = null;
  },

  onTimerEvent: function() {
    if (!this.currentlyExecuting) {
      try {
        this.currentlyExecuting = true;
        this.callback(this);
      } finally {
        this.currentlyExecuting = false;
      }
    }
  }
}
Object.extend(String, {
  interpret: function(value) {
    return value == null ? '' : String(value);
  },
  specialChar: {
    '\b': '\\b',
    '\t': '\\t',
    '\n': '\\n',
    '\f': '\\f',
    '\r': '\\r',
    '\\': '\\\\'
  }
});

Object.extend(String.prototype, {
  gsub: function(pattern, replacement) {
    var result = '', source = this, match;
    replacement = arguments.callee.prepareReplacement(replacement);

    while (source.length > 0) {
      if (match = source.match(pattern)) {
        result += source.slice(0, match.index);
        result += String.interpret(replacement(match));
        source  = source.slice(match.index + match[0].length);
      } else {
        result += source, source = '';
      }
    }
    return result;
  },

  sub: function(pattern, replacement, count) {
    replacement = this.gsub.prepareReplacement(replacement);
    count = count === undefined ? 1 : count;

    return this.gsub(pattern, function(match) {
      if (--count < 0) return match[0];
      return replacement(match);
    });
  },

  scan: function(pattern, iterator) {
    this.gsub(pattern, iterator);
    return String(this);
  },

  truncate: function(length, truncation) {
    length = length || 30;
    truncation = truncation === undefined ? '...' : truncation;
    return this.length > length ?
      this.slice(0, length - truncation.length) + truncation : String(this);
  },

  strip: function() {
    return this.replace(/^\s+/, '').replace(/\s+$/, '');
  },

  stripTags: function() {
    return this.replace(/<\/?[^>]+>/gi, '');
  },

  stripScripts: function() {
    return this.replace(new RegExp(Prototype.ScriptFragment, 'img'), '');
  },

  extractScripts: function() {
    var matchAll = new RegExp(Prototype.ScriptFragment, 'img');
    var matchOne = new RegExp(Prototype.ScriptFragment, 'im');
    return (this.match(matchAll) || []).map(function(scriptTag) {
      return (scriptTag.match(matchOne) || ['', ''])[1];
    });
  },

  evalScripts: function() {
    return this.extractScripts().map(function(script) { return eval(script) });
  },

  escapeHTML: function() {
    var self = arguments.callee;
    self.text.data = this;
    return self.div.innerHTML;
  },

  unescapeHTML: function() {
    var div = new Element('div');
    div.innerHTML = this.stripTags();
    return div.childNodes[0] ? (div.childNodes.length > 1 ?
      $A(div.childNodes).inject('', function(memo, node) { return memo+node.nodeValue }) :
      div.childNodes[0].nodeValue) : '';
  },

  toQueryParams: function(separator) {
    var match = this.strip().match(/([^?#]*)(#.*)?$/);
    if (!match) return {};

    return match[1].split(separator || '&').inject({}, function(hash, pair) {
      if ((pair = pair.split('='))[0]) {
        var key = decodeURIComponent(pair.shift());
        var value = pair.length > 1 ? pair.join('=') : pair[0];
        if (value != undefined) value = decodeURIComponent(value);

        if (key in hash) {
          if (!Object.isArray(hash[key])) hash[key] = [hash[key]];
          hash[key].push(value);
        }
        else hash[key] = value;
      }
      return hash;
    });
  },

  toArray: function() {
    return this.split('');
  },

  succ: function() {
    return this.slice(0, this.length - 1) +
      String.fromCharCode(this.charCodeAt(this.length - 1) + 1);
  },

  times: function(count) {
    var result = '';
    for (var i = 0; i < count; i++) result += this;
    return result;
  },

  camelize: function() {
    var parts = this.split('-'), len = parts.length;
    if (len == 1) return parts[0];

    var camelized = this.charAt(0) == '-'
      ? parts[0].charAt(0).toUpperCase() + parts[0].substring(1)
      : parts[0];

    for (var i = 1; i < len; i++)
      camelized += parts[i].charAt(0).toUpperCase() + parts[i].substring(1);

    return camelized;
  },

  capitalize: function() {
    return this.charAt(0).toUpperCase() + this.substring(1).toLowerCase();
  },

  underscore: function() {
    return this.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'#{1}_#{2}').gsub(/([a-z\d])([A-Z])/,'#{1}_#{2}').gsub(/-/,'_').toLowerCase();
  },

  dasherize: function() {
    return this.gsub(/_/,'-');
  },

  inspect: function(useDoubleQuotes) {
    var escapedString = this.gsub(/[\x00-\x1f\\]/, function(match) {
      var character = String.specialChar[match[0]];
      return character ? character : '\\u00' + match[0].charCodeAt().toPaddedString(2, 16);
    });
    if (useDoubleQuotes) return '"' + escapedString.replace(/"/g, '\\"') + '"';
    return "'" + escapedString.replace(/'/g, '\\\'') + "'";
  },

  toJSON: function() {
    return this.inspect(true);
  },

  unfilterJSON: function(filter) {
    return this.sub(filter || Prototype.JSONFilter, '#{1}');
  },

  isJSON: function() {
    var str = this.replace(/\\./g, '@').replace(/"[^"\\\n\r]*"/g, '');
    return (/^[,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]*$/).test(str);
  },

  evalJSON: function(sanitize) {
    var json = this.unfilterJSON();
    try {
      if (!sanitize || json.isJSON()) return eval('(' + json + ')');
    } catch (e) { }
    throw new SyntaxError('Badly formed JSON string: ' + this.inspect());
  },

  include: function(pattern) {
    return this.indexOf(pattern) > -1;
  },

  startsWith: function(pattern) {
    return this.indexOf(pattern) === 0;
  },

  endsWith: function(pattern) {
    var d = this.length - pattern.length;
    return d >= 0 && this.lastIndexOf(pattern) === d;
  },

  empty: function() {
    return this == '';
  },

  blank: function() {
    return /^\s*$/.test(this);
  },

  interpolate: function(object, pattern) {
    return new Template(this, pattern).evaluate(object);
  }
});

if (Prototype.Browser.WebKit || Prototype.Browser.IE) Object.extend(String.prototype, {
  escapeHTML: function() {
    return this.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  },
  unescapeHTML: function() {
    return this.replace(/&amp;/g,'&').replace(/&lt;/g,'<').replace(/&gt;/g,'>');
  }
});

String.prototype.gsub.prepareReplacement = function(replacement) {
  if (typeof replacement == 'function') return replacement;
  var template = new Template(replacement);
  return function(match) { return template.evaluate(match) };
}

String.prototype.parseQuery = String.prototype.toQueryParams;

Object.extend(String.prototype.escapeHTML, {
  div:  document.createElement('div'),
  text: document.createTextNode('')
});

with (String.prototype.escapeHTML) div.appendChild(text);

var Template = Class.create();
Template.Pattern = /(^|.|\r|\n)(#\{(.*?)\})/;
Template.prototype = {
  initialize: function(template, pattern) {
    this.template = template.toString();
    this.pattern = pattern || Template.Pattern;
  },

  evaluate: function(object) {
    if (typeof object.toTemplateReplacements == 'function')
      object = object.toTemplateReplacements();

    return this.template.gsub(this.pattern, function(match) {
      if (object == null) return '';

      var before = match[1] || '';
      if (before == '\\') return match[2];

      var ctx = object, expr = match[3];
      var pattern = /^([^.[]+|\[((?:.*?[^\\])?)\])(\.|\[|$)/, match = pattern.exec(expr);
      if (match == null) return '';

      while (match != null) {
        var comp = match[1].startsWith('[') ? match[2].gsub('\\\\]', ']') : match[1];
        ctx = ctx[comp];
        if (null == ctx || '' == match[3]) break;
        expr = expr.substring('[' == match[3] ? match[1].length : match[0].length);
        match = pattern.exec(expr);
      }

      return before + String.interpret(ctx);
    }.bind(this));
  }
};

var $break = {};

var Enumerable = {
  each: function(iterator, context) {
    var index = 0;
    iterator = iterator.bind(context);
    try {
      this._each(function(value) {
        iterator(value, index++);
      });
    } catch (e) {
      if (e != $break) throw e;
    }
    return this;
  },

  eachSlice: function(number, iterator, context) {
    iterator = iterator ? iterator.bind(context) : Prototype.K;
    var index = -number, slices = [], array = this.toArray();
    while ((index += number) < array.length)
      slices.push(array.slice(index, index+number));
    return slices.collect(iterator, context);
  },

  all: function(iterator, context) {
    iterator = iterator ? iterator.bind(context) : Prototype.K;
    var result = true;
    this.each(function(value, index) {
      result = result && !!iterator(value, index);
      if (!result) throw $break;
    });
    return result;
  },

  any: function(iterator, context) {
    iterator = iterator ? iterator.bind(context) : Prototype.K;
    var result = false;
    this.each(function(value, index) {
      if (result = !!iterator(value, index))
        throw $break;
    });
    return result;
  },

  collect: function(iterator, context) {
    iterator = iterator ? iterator.bind(context) : Prototype.K;
    var results = [];
    this.each(function(value, index) {
      results.push(iterator(value, index));
    });
    return results;
  },

  detect: function(iterator, context) {
    iterator = iterator.bind(context);
    var result;
    this.each(function(value, index) {
      if (iterator(value, index)) {
        result = value;
        throw $break;
      }
    });
    return result;
  },

  findAll: function(iterator, context) {
    iterator = iterator.bind(context);
    var results = [];
    this.each(function(value, index) {
      if (iterator(value, index))
        results.push(value);
    });
    return results;
  },

  grep: function(filter, iterator, context) {
    iterator = iterator ? iterator.bind(context) : Prototype.K;
    var results = [];

    if (typeof filter == "string")
      filter = new RegExp(filter);

    this.each(function(value, index) {
      if (filter.match(value))
        results.push(iterator(value, index));
    });
    return results;
  },

  include: function(object) {
    if (typeof this.indexOf == 'function')
      return this.indexOf(object) != -1;

    var found = false;
    this.each(function(value) {
      if (value === object) {
        found = true;
        throw $break;
      }
    });
    return found;
  },

  inGroupsOf: function(number, fillWith) {
    fillWith = fillWith === undefined ? null : fillWith;
    return this.eachSlice(number, function(slice) {
      while(slice.length < number) slice.push(fillWith);
      return slice;
    });
  },

  inject: function(memo, iterator, context) {
    iterator = iterator.bind(context);
    this.each(function(value, index) {
      memo = iterator(memo, value, index);
    });
    return memo;
  },

  invoke: function(method) {
    var args = $A(arguments).slice(1);
    return this.map(function(value) {
      return value[method].apply(value, args);
    });
  },

  max: function(iterator, context) {
    iterator = iterator ? iterator.bind(context) : Prototype.K;
    var result;
    this.each(function(value, index) {
      value = iterator(value, index);
      if (result == undefined || value >= result)
        result = value;
    });
    return result;
  },

  min: function(iterator, context) {
    iterator = iterator ? iterator.bind(context) : Prototype.K;
    var result;
    this.each(function(value, index) {
      value = iterator(value, index);
      if (result == undefined || value < result)
        result = value;
    });
    return result;
  },

  partition: function(iterator, context) {
    iterator = iterator ? iterator.bind(context) : Prototype.K;
    var trues = [], falses = [];
    this.each(function(value, index) {
      (iterator(value, index) ?
        trues : falses).push(value);
    });
    return [trues, falses];
  },

  pluck: function(property) {
    var results = [];
    this.each(function(value) {
      results.push(value[property]);
    });
    return results;
  },

  reject: function(iterator, context) {
    iterator = iterator.bind(context);
    var results = [];
    this.each(function(value, index) {
      if (!iterator(value, index))
        results.push(value);
    });
    return results;
  },

  sortBy: function(iterator, context) {
    iterator = iterator.bind(context);
    return this.map(function(value, index) {
      return {value: value, criteria: iterator(value, index)};
    }).sort(function(left, right) {
      var a = left.criteria, b = right.criteria;
      return a < b ? -1 : a > b ? 1 : 0;
    }).pluck('value');
  },

  toArray: function() {
    return this.map();
  },

  zip: function() {
    var iterator = Prototype.K, args = $A(arguments);
    if (typeof args.last() == 'function')
      iterator = args.pop();

    var collections = [this].concat(args).map($A);
    return this.map(function(value, index) {
      return iterator(collections.pluck(index));
    });
  },

  size: function() {
    return this.toArray().length;
  },

  inspect: function() {
    return '#<Enumerable:' + this.toArray().inspect() + '>';
  }
}

Object.extend(Enumerable, {
  map:     Enumerable.collect,
  find:    Enumerable.detect,
  select:  Enumerable.findAll,
  filter:  Enumerable.findAll,
  member:  Enumerable.include,
  entries: Enumerable.toArray,
  every:   Enumerable.all,
  some:    Enumerable.any
});
function $A(iterable) {
  if (!iterable) return [];
  if (iterable.toArray) return iterable.toArray();
  else {
    var results = [];
    for (var i = 0, length = iterable.length; i < length; i++)
      results.push(iterable[i]);
    return results;
  }
}

if (Prototype.Browser.WebKit) {
  function $A(iterable) {
    if (!iterable) return [];
    if (!(typeof iterable == 'function' && iterable == '[object NodeList]') &&
      iterable.toArray) {
      return iterable.toArray();
    } else {
      var results = [];
      for (var i = 0, length = iterable.length; i < length; i++)
        results.push(iterable[i]);
      return results;
    }
  }
}

Array.from = $A;

Object.extend(Array.prototype, Enumerable);

if (!Array.prototype._reverse) Array.prototype._reverse = Array.prototype.reverse;

Object.extend(Array.prototype, {
  _each: function(iterator) {
    for (var i = 0, length = this.length; i < length; i++)
      iterator(this[i]);
  },

  clear: function() {
    this.length = 0;
    return this;
  },

  first: function() {
    return this[0];
  },

  last: function() {
    return this[this.length - 1];
  },

  compact: function() {
    return this.select(function(value) {
      return value != null;
    });
  },

  flatten: function() {
    return this.inject([], function(array, value) {
      return array.concat(Object.isArray(value) ?
        value.flatten() : [value]);
    });
  },

  without: function() {
    var values = $A(arguments);
    return this.select(function(value) {
      return !values.include(value);
    });
  },

  reverse: function(inline) {
    return (inline !== false ? this : this.toArray())._reverse();
  },

  reduce: function() {
    return this.length > 1 ? this : this[0];
  },

  uniq: function(sorted) {
    return this.inject([], function(array, value, index) {
      if (0 == index || (sorted ? array.last() != value : !array.include(value)))
        array.push(value);
      return array;
    });
  },

  intersect: function(array) {
    return this.uniq().findAll(function(item) {
      return array.include(item);
    });
  },

  clone: function() {
    return [].concat(this);
  },

  size: function() {
    return this.length;
  },

  inspect: function() {
    return '[' + this.map(Object.inspect).join(', ') + ']';
  },

  toJSON: function() {
    var results = [];
    this.each(function(object) {
      var value = Object.toJSON(object);
      if (value !== undefined) results.push(value);
    });
    return '[' + results.join(', ') + ']';
  }
});

// use native browser JS 1.6 implementation if available
if (typeof Array.prototype.forEach == 'function')
  Array.prototype._each = Array.prototype.forEach;

if (!Array.prototype.indexOf) Array.prototype.indexOf = function(item, i) {
  i || (i = 0);
  var length = this.length;
  if (i < 0) i = length + i;
  for (; i < length; i++)
    if (this[i] === item) return i;
  return -1;
}

if (!Array.prototype.lastIndexOf) Array.prototype.lastIndexOf = function(item, i) {
  i = isNaN(i) ? this.length : (i < 0 ? this.length + i : i) + 1;
  var n = this.slice(0, i).reverse().indexOf(item);
  return (n < 0) ? n : i - n - 1;
}

Array.prototype.toArray = Array.prototype.clone;

function $w(string) {
  string = string.strip();
  return string ? string.split(/\s+/) : [];
}

if (Prototype.Browser.Opera){
  Array.prototype.concat = function() {
    var array = [];
    for (var i = 0, length = this.length; i < length; i++) array.push(this[i]);
    for (var i = 0, length = arguments.length; i < length; i++) {
      if (Object.isArray(arguments[i])) {
        for (var j = 0, arrayLength = arguments[i].length; j < arrayLength; j++)
          array.push(arguments[i][j]);
      } else {
        array.push(arguments[i]);
      }
    }
    return array;
  }
}
Object.extend(Number.prototype, {
  toColorPart: function() {
    return this.toPaddedString(2, 16);
  },

  succ: function() {
    return this + 1;
  },

  times: function(iterator) {
    $R(0, this, true).each(iterator);
    return this;
  },

  toPaddedString: function(length, radix) {
    var string = this.toString(radix || 10);
    return '0'.times(length - string.length) + string;
  },

  toJSON: function() {
    return isFinite(this) ? this.toString() : 'null';
  }
});

$w('abs round ceil floor').each(function(method){
  Number.prototype[method] = Math[method].methodize()
});
var Hash = function(object) {
  if (object instanceof Hash) this.merge(object);
  else Object.extend(this, object || {});
};

Object.extend(Hash, {
  toQueryString: function(obj) {
    var parts = [];
    parts.add = arguments.callee.addPair;

    this.prototype._each.call(obj, function(pair) {
      if (!pair.key) return;
      var value = pair.value;

      if (value && typeof value == 'object') {
        if (Object.isArray(value)) value.each(function(value) {
          parts.add(pair.key, value);
        });
        return;
      }
      parts.add(pair.key, value);
    });

    return parts.join('&');
  },

  toJSON: function(object) {
    var results = [];
    this.prototype._each.call(object, function(pair) {
      var value = Object.toJSON(pair.value);
      if (value !== undefined) results.push(pair.key.toJSON() + ': ' + value);
    });
    return '{' + results.join(', ') + '}';
  }
});

Hash.toQueryString.addPair = function(key, value, prefix) {
  key = encodeURIComponent(key);
  if (value === undefined) this.push(key);
  else this.push(key + '=' + (value == null ? '' : encodeURIComponent(value)));
}

Object.extend(Hash.prototype, Enumerable);
Object.extend(Hash.prototype, {
  _each: function(iterator) {
    for (var key in this) {
      var value = this[key];
      if (value && value == Hash.prototype[key]) continue;

      var pair = [key, value];
      pair.key = key;
      pair.value = value;
      iterator(pair);
    }
  },

  keys: function() {
    return this.pluck('key');
  },

  values: function() {
    return this.pluck('value');
  },

  index: function(value) {
    var match = this.detect(function(pair) {
      return pair.value === value;
    });
    return match && match.key;
  },

  merge: function(hash) {
    return $H(hash).inject(this, function(mergedHash, pair) {
      mergedHash[pair.key] = pair.value;
      return mergedHash;
    });
  },

  remove: function() {
    var result;
    for(var i = 0, length = arguments.length; i < length; i++) {
      var value = this[arguments[i]];
      if (value !== undefined){
        if (result === undefined) result = value;
        else {
          if (!Object.isArray(result)) result = [result];
          result.push(value)
        }
      }
      delete this[arguments[i]];
    }
    return result;
  },

  toQueryString: function() {
    return Hash.toQueryString(this);
  },

  inspect: function() {
    return '#<Hash:{' + this.map(function(pair) {
      return pair.map(Object.inspect).join(': ');
    }).join(', ') + '}>';
  },

  toJSON: function() {
    return Hash.toJSON(this);
  }
});

function $H(object) {
  if (object instanceof Hash) return object;
  return new Hash(object);
};

// Safari iterates over shadowed properties
if (function() {
  var i = 0, Test = function(value) { this.key = value };
  Test.prototype.key = 'foo';
  for (var property in new Test('bar')) i++;
  return i > 1;
}()) Hash.prototype._each = function(iterator) {
  var cache = [];
  for (var key in this) {
    var value = this[key];
    if ((value && value == Hash.prototype[key]) || cache.include(key)) continue;
    cache.push(key);
    var pair = [key, value];
    pair.key = key;
    pair.value = value;
    iterator(pair);
  }
};
ObjectRange = Class.create();
Object.extend(ObjectRange.prototype, Enumerable);
Object.extend(ObjectRange.prototype, {
  initialize: function(start, end, exclusive) {
    this.start = start;
    this.end = end;
    this.exclusive = exclusive;
  },

  _each: function(iterator) {
    var value = this.start;
    while (this.include(value)) {
      iterator(value);
      value = value.succ();
    }
  },

  include: function(value) {
    if (value < this.start)
      return false;
    if (this.exclusive)
      return value < this.end;
    return value <= this.end;
  }
});

var $R = function(start, end, exclusive) {
  return new ObjectRange(start, end, exclusive);
}

var Ajax = {
  getTransport: function() {
    return Try.these(
      function() {return new XMLHttpRequest()},
      function() {return new ActiveXObject('Msxml2.XMLHTTP')},
      function() {return new ActiveXObject('Microsoft.XMLHTTP')}
    ) || false;
  },

  activeRequestCount: 0
}

Ajax.Responders = {
  responders: [],

  _each: function(iterator) {
    this.responders._each(iterator);
  },

  register: function(responder) {
    if (!this.include(responder))
      this.responders.push(responder);
  },

  unregister: function(responder) {
    this.responders = this.responders.without(responder);
  },

  dispatch: function(callback, request, transport, json) {
    this.each(function(responder) {
      if (typeof responder[callback] == 'function') {
        try {
          responder[callback].apply(responder, [request, transport, json]);
        } catch (e) {}
      }
    });
  }
};

Object.extend(Ajax.Responders, Enumerable);

Ajax.Responders.register({
  onCreate: function() {
    Ajax.activeRequestCount++;
  },
  onComplete: function() {
    Ajax.activeRequestCount--;
  }
});

Ajax.Base = function() {};
Ajax.Base.prototype = {
  setOptions: function(options) {
    this.options = {
      method:       'post',
      asynchronous: true,
      contentType:  'application/x-www-form-urlencoded',
      encoding:     'UTF-8',
      parameters:   ''
    }
    Object.extend(this.options, options || {});

    this.options.method = this.options.method.toLowerCase();
    if (typeof this.options.parameters == 'string')
      this.options.parameters = this.options.parameters.toQueryParams();
  }
}

Ajax.Request = Class.create();
Ajax.Request.Events =
  ['Uninitialized', 'Loading', 'Loaded', 'Interactive', 'Complete'];

Ajax.Request.prototype = Object.extend(new Ajax.Base(), {
  _complete: false,

  initialize: function(url, options) {
    this.transport = Ajax.getTransport();
    this.setOptions(options);
    this.request(url);
  },

  request: function(url) {
    this.url = url;
    this.method = this.options.method;
    var params = Object.clone(this.options.parameters);

    if (!['get', 'post'].include(this.method)) {
      // simulate other verbs over post
      params['_method'] = this.method;
      this.method = 'post';
    }

    this.parameters = params;

    if (params = Hash.toQueryString(params)) {
      // when GET, append parameters to URL
      if (this.method == 'get')
        this.url += (this.url.include('?') ? '&' : '?') + params;
      else if (/Konqueror|Safari|KHTML/.test(navigator.userAgent))
        params += '&_=';
    }

    try {
      if (this.options.onCreate) this.options.onCreate(this.transport);
      Ajax.Responders.dispatch('onCreate', this, this.transport);

      this.transport.open(this.method.toUpperCase(), this.url,
        this.options.asynchronous);

      if (this.options.asynchronous) this.respondToReadyState.bind(this).defer(1);

      this.transport.onreadystatechange = this.onStateChange.bind(this);
      this.setRequestHeaders();

      this.body = this.method == 'post' ? (this.options.postBody || params) : null;
      this.transport.send(this.body);

      /* Force Firefox to handle ready state 4 for synchronous requests */
      if (!this.options.asynchronous && this.transport.overrideMimeType)
        this.onStateChange();

    }
    catch (e) {
      this.dispatchException(e);
    }
  },

  onStateChange: function() {
    var readyState = this.transport.readyState;
    if (readyState > 1 && !((readyState == 4) && this._complete))
      this.respondToReadyState(this.transport.readyState);
  },

  setRequestHeaders: function() {
    var headers = {
      'X-Requested-With': 'XMLHttpRequest',
      'X-Prototype-Version': Prototype.Version,
      'Accept': 'text/javascript, text/html, application/xml, text/xml, */*'
    };

    if (this.method == 'post') {
      headers['Content-type'] = this.options.contentType +
        (this.options.encoding ? '; charset=' + this.options.encoding : '');

      /* Force "Connection: close" for older Mozilla browsers to work
       * around a bug where XMLHttpRequest sends an incorrect
       * Content-length header. See Mozilla Bugzilla #246651.
       */
      if (this.transport.overrideMimeType &&
          (navigator.userAgent.match(/Gecko\/(\d{4})/) || [0,2005])[1] < 2005)
            headers['Connection'] = 'close';
    }

    // user-defined headers
    if (typeof this.options.requestHeaders == 'object') {
      var extras = this.options.requestHeaders;

      if (typeof extras.push == 'function')
        for (var i = 0, length = extras.length; i < length; i += 2)
          headers[extras[i]] = extras[i+1];
      else
        $H(extras).each(function(pair) { headers[pair.key] = pair.value });
    }

    for (var name in headers)
      this.transport.setRequestHeader(name, headers[name]);
  },

  success: function() {
    return !this.transport.status
        || (this.transport.status >= 200 && this.transport.status < 300);
  },

  respondToReadyState: function(readyState) {
    var state = Ajax.Request.Events[readyState];
    var transport = this.transport, json = this.evalJSON();

    if (state == 'Complete') {
      try {
        this._complete = true;
        (this.options['on' + this.transport.status]
         || this.options['on' + (this.success() ? 'Success' : 'Failure')]
         || Prototype.emptyFunction)(transport, json);
      } catch (e) {
        this.dispatchException(e);
      }

      var contentType = this.getHeader('Content-type');
      if (contentType && contentType.strip().
        match(/^(text|application)\/(x-)?(java|ecma)script(;.*)?$/i))
          this.evalResponse();
    }

    try {
      (this.options['on' + state] || Prototype.emptyFunction)(transport, json);
      Ajax.Responders.dispatch('on' + state, this, transport, json);
    } catch (e) {
      this.dispatchException(e);
    }

    if (state == 'Complete') {
      // avoid memory leak in MSIE: clean up
      this.transport.onreadystatechange = Prototype.emptyFunction;
    }
  },

  getHeader: function(name) {
    try {
      return this.transport.getResponseHeader(name);
    } catch (e) { return null }
  },

  evalJSON: function() {
    try {
      var json = this.getHeader('X-JSON');
      return json ? json.evalJSON() : null;
    } catch (e) { return null }
  },

  evalResponse: function() {
    try {
      return eval((this.transport.responseText || '').unfilterJSON());
    } catch (e) {
      this.dispatchException(e);
    }
  },

  dispatchException: function(exception) {
    (this.options.onException || Prototype.emptyFunction)(this, exception);
    Ajax.Responders.dispatch('onException', this, exception);
  }
});

Ajax.Updater = Class.create();

Object.extend(Object.extend(Ajax.Updater.prototype, Ajax.Request.prototype), {
  initialize: function(container, url, options) {
    this.container = {
      success: (container.success || container),
      failure: (container.failure || (container.success ? null : container))
    }

    this.transport = Ajax.getTransport();
    this.setOptions(options);

    var onComplete = this.options.onComplete || Prototype.emptyFunction;
    this.options.onComplete = (function(transport, param) {
      this.updateContent();
      onComplete(transport, param);
    }).bind(this);

    this.request(url);
  },

  updateContent: function() {
    var receiver = this.container[this.success() ? 'success' : 'failure'];
    var response = this.transport.responseText, options = this.options;

    if (!options.evalScripts) response = response.stripScripts();

    if (receiver = $(receiver)) {
      if (options.insertion) {
        if (typeof options.insertion == 'string') {
          var insertion = {}; insertion[options.insertion] = response;
          receiver.insert(insertion);
        }
        else options.insertion(receiver, response);
      }
      else receiver.update(response);
    }

    if (this.success()) {
      if (this.onComplete) this.onComplete.bind(this).defer();
    }
  }
});

Ajax.PeriodicalUpdater = Class.create();
Ajax.PeriodicalUpdater.prototype = Object.extend(new Ajax.Base(), {
  initialize: function(container, url, options) {
    this.setOptions(options);
    this.onComplete = this.options.onComplete;

    this.frequency = (this.options.frequency || 2);
    this.decay = (this.options.decay || 1);

    this.updater = {};
    this.container = container;
    this.url = url;

    this.start();
  },

  start: function() {
    this.options.onComplete = this.updateComplete.bind(this);
    this.onTimerEvent();
  },

  stop: function() {
    this.updater.options.onComplete = undefined;
    clearTimeout(this.timer);
    (this.onComplete || Prototype.emptyFunction).apply(this, arguments);
  },

  updateComplete: function(request) {
    if (this.options.decay) {
      this.decay = (request.responseText == this.lastText ?
        this.decay * this.options.decay : 1);

      this.lastText = request.responseText;
    }
    this.timer = this.onTimerEvent.bind(this).delay(this.decay * this.frequency);
  },

  onTimerEvent: function() {
    this.updater = new Ajax.Updater(this.container, this.url, this.options);
  }
});
function $(element) {
  if (arguments.length > 1) {
    for (var i = 0, elements = [], length = arguments.length; i < length; i++)
      elements.push($(arguments[i]));
    return elements;
  }
  if (typeof element == 'string')
    element = document.getElementById(element);
  return Element.extend(element);
}

if (Prototype.BrowserFeatures.XPath) {
  document._getElementsByXPath = function(expression, parentElement) {
    var results = [];
    var query = document.evaluate(expression, $(parentElement) || document,
      null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
    for (var i = 0, length = query.snapshotLength; i < length; i++)
      results.push(query.snapshotItem(i));
    return results;
  };
}

/*--------------------------------------------------------------------------*/

(function() {
  var element = this.Element;
  this.Element = function(tagName, attributes) {
    attributes = attributes || {};
    tagName = tagName.toLowerCase();
    var cache = Element.cache;
    if (Prototype.Browser.IE && attributes.name) {
      tagName = '<' + tagName + ' name="' + attributes.name + '">';
      delete attributes.name;
      return Element.writeAttribute(document.createElement(tagName), attributes);
    }
    if (!cache[tagName]) cache[tagName] = Element.extend(document.createElement(tagName));
    return Element.writeAttribute(cache[tagName].cloneNode(false), attributes);
  };
  Object.extend(this.Element, element || {});
}).call(window);

Element.cache = {};

Element.Methods = {
  visible: function(element) {
    return $(element).style.display != 'none';
  },

  toggle: function(element) {
    element = $(element);
    Element[Element.visible(element) ? 'hide' : 'show'](element);
    return element;
  },

  hide: function(element) {
    $(element).style.display = 'none';
    return element;
  },

  show: function(element) {
    $(element).style.display = '';
    return element;
  },

  remove: function(element) {
    element = $(element);
    element.parentNode.removeChild(element);
    return element;
  },

  update: function(element, content) {
    element = $(element);
    if (content && content.toElement) content = content.toElement();
    if (Object.isElement(content)) return element.update().insert(content);
    content = Object.toHTML(content);
    element.innerHTML = content.stripScripts();
    content.evalScripts.bind(content).defer();
    return element;
  },

  replace: function(element, content) {
    element = $(element);
    if (content && content.toElement) content = content.toElement();
    else if (!Object.isElement(content)) {
      content = Object.toHTML(content);
      var range = element.ownerDocument.createRange();
      range.selectNode(element);
      content.evalScripts.bind(content).defer();
      content = range.createContextualFragment(content.stripScripts());
    }
    element.parentNode.replaceChild(content, element);
    return element;
  },

  insert: function(element, insertions) {
    element = $(element);

    if (typeof insertions == 'string' || typeof insertions == 'number' ||
        Object.isElement(insertions) || (insertions && (insertions.toElement || insertions.toHTML)))
          insertions = {bottom:insertions};

    var content, t, range;

    for (position in insertions) {
      content  = insertions[position];
      position = position.toLowerCase();
      t = Element._insertionTranslations[position];

      if (content && content.toElement) content = content.toElement();
      if (Object.isElement(content)) {
        t.insert(element, content);
        continue;
      }

      content = Object.toHTML(content);

      range = element.ownerDocument.createRange();
      t.initializeRange(element, range);
      t.insert(element, range.createContextualFragment(content.stripScripts()));

      content.evalScripts.bind(content).defer();
    }

    return element;
  },

  wrap: function(element, wrapper, attributes) {
    element = $(element);
    if (Object.isElement(wrapper))
      $(wrapper).writeAttribute(attributes || {});
    else if (typeof wrapper == 'string') wrapper = new Element(wrapper, attributes);
    else wrapper = new Element('div', wrapper);
    if (element.parentNode)
      element.parentNode.replaceChild(wrapper, element);
    wrapper.appendChild(element);
    return element;
  },

  inspect: function(element) {
    element = $(element);
    var result = '<' + element.tagName.toLowerCase();
    $H({'id': 'id', 'className': 'class'}).each(function(pair) {
      var property = pair.first(), attribute = pair.last();
      var value = (element[property] || '').toString();
      if (value) result += ' ' + attribute + '=' + value.inspect(true);
    });
    return result + '>';
  },

  recursivelyCollect: function(element, property) {
    element = $(element);
    var elements = [];
    while (element = element[property])
      if (element.nodeType == 1)
        elements.push(Element.extend(element));
    return elements;
  },

  ancestors: function(element) {
    return $(element).recursivelyCollect('parentNode');
  },

  descendants: function(element) {
    return $A($(element).getElementsByTagName('*')).each(Element.extend);
  },

  firstDescendant: function(element) {
    element = $(element).firstChild;
    while (element && element.nodeType != 1) element = element.nextSibling;
    return $(element);
  },

  immediateDescendants: function(element) {
    if (!(element = $(element).firstChild)) return [];
    while (element && element.nodeType != 1) element = element.nextSibling;
    if (element) return [element].concat($(element).nextSiblings());
    return [];
  },

  previousSiblings: function(element) {
    return $(element).recursivelyCollect('previousSibling');
  },

  nextSiblings: function(element) {
    return $(element).recursivelyCollect('nextSibling');
  },

  siblings: function(element) {
    element = $(element);
    return element.previousSiblings().reverse().concat(element.nextSiblings());
  },

  match: function(element, selector) {
    if (typeof selector == 'string')
      selector = new Selector(selector);
    return selector.match($(element));
  },

  up: function(element, expression, index) {
    element = $(element);
    if (arguments.length == 1) return $(element.parentNode);
    var ancestors = element.ancestors();
    return expression ? Selector.findElement(ancestors, expression, index) :
      ancestors[index || 0];
  },

  down: function(element, expression, index) {
    element = $(element);
    if (arguments.length == 1) return element.firstDescendant();
    var descendants = element.descendants();
    return expression ? Selector.findElement(descendants, expression, index) :
      descendants[index || 0];
  },

  previous: function(element, expression, index) {
    element = $(element);
    if (arguments.length == 1) return $(Selector.handlers.previousElementSibling(element));
    var previousSiblings = element.previousSiblings();
    return expression ? Selector.findElement(previousSiblings, expression, index) :
      previousSiblings[index || 0];
  },

  next: function(element, expression, index) {
    element = $(element);
    if (arguments.length == 1) return $(Selector.handlers.nextElementSibling(element));
    var nextSiblings = element.nextSiblings();
    return expression ? Selector.findElement(nextSiblings, expression, index) :
      nextSiblings[index || 0];
  },

  select: function() {
    var args = $A(arguments), element = $(args.shift());
    return Selector.findChildElements(element, args);
  },

  adjacent: function() {
    var args = $A(arguments), element = $(args.shift());
    return Selector.findChildElements(element.parentNode, args).without(element);
  },

  identify: function(element) {
    element = $(element);
    var id = element.readAttribute('id'), self = arguments.callee;
    if (id) return id;
    do { id = 'anonymous_element_' + self.counter++ } while ($(id));
    element.writeAttribute('id', id);
    return id;
  },

  readAttribute: function(element, name) {
    element = $(element);
    if (Prototype.Browser.IE) {
      var t = Element._attributeTranslations.read;
      if (t.values[name]) return t.values[name](element, name);
      if (t.names[name]) name = t.names[name];
    }
    return element.getAttribute(name);
  },

  writeAttribute: function(element, name, value) {
    element = $(element);
    var attributes = {}, t = Element._attributeTranslations.write;

    if (typeof name == 'object') attributes = name;
    else attributes[name] = value === undefined ? true : value;

    for (var attr in attributes) {
      var name = t.names[attr] || attr, value = attributes[attr];
      if (t.values[attr]) name = t.values[attr](element, value);
      if (value === false || value === null)
        element.removeAttribute(name);
      else if (value === true)
        element.setAttribute(name, name);
      else element.setAttribute(name, value);
    }
    return element;
  },

  getHeight: function(element) {
    return $(element).getDimensions().height;
  },

  getWidth: function(element) {
    return $(element).getDimensions().width;
  },

  classNames: function(element) {
    return new Element.ClassNames(element);
  },

  hasClassName: function(element, className) {
    if (!(element = $(element))) return;
    var elementClassName = element.className;
    return (elementClassName.length > 0 && (elementClassName == className ||
      elementClassName.match(new RegExp("(^|\\s)" + className + "(\\s|$)"))));
  },

  addClassName: function(element, className) {
    if (!(element = $(element))) return;
    if (!element.hasClassName(className))
      element.className += (element.className ? ' ' : '') + className;
    return element;
  },

  removeClassName: function(element, className) {
    if (!(element = $(element))) return;
    element.className = element.className.replace(
      new RegExp("(^|\\s+)" + className + "(\\s+|$)"), ' ').strip();
    return element;
  },

  toggleClassName: function(element, className) {
    if (!(element = $(element))) return;
    return element[element.hasClassName(className) ?
      'removeClassName' : 'addClassName'](className);
  },

  observe: function() {
    Event.observe.apply(Event, arguments);
    return $A(arguments).first();
  },

  stopObserving: function() {
    Event.stopObserving.apply(Event, arguments);
    return $A(arguments).first();
  },

  // removes whitespace-only text node children
  cleanWhitespace: function(element) {
    element = $(element);
    var node = element.firstChild;
    while (node) {
      var nextNode = node.nextSibling;
      if (node.nodeType == 3 && !/\S/.test(node.nodeValue))
        element.removeChild(node);
      node = nextNode;
    }
    return element;
  },

  empty: function(element) {
    return $(element).innerHTML.blank();
  },

  descendantOf: function(element, ancestor) {
    element = $(element), ancestor = $(ancestor);
    while (element = element.parentNode)
      if (element == ancestor) return true;
    return false;
  },

  scrollTo: function(element) {
    element = $(element);
    var pos = element.cumulativeOffset();
    window.scrollTo(pos[0], pos[1]);
    return element;
  },

  getStyle: function(element, style) {
    element = $(element);
    style = style == 'float' ? 'cssFloat' : style.camelize();
    var value = element.style[style];
    if (!value) {
      var css = document.defaultView.getComputedStyle(element, null);
      value = css ? css[style] : null;
    }
    if (style == 'opacity') return value ? parseFloat(value) : 1.0;
    return value == 'auto' ? null : value;
  },

  getOpacity: function(element) {
    return $(element).getStyle('opacity');
  },

  setStyle: function(element, styles) {
    element = $(element);
    var elementStyle = element.style, match;
    if (typeof styles === 'string') {
      element.style.cssText += ';' + styles;
      return styles.include('opacity') ?
        element.setOpacity(styles.match(/opacity:\s*(\d?\.?\d*)/)[1]) : element;
    }
    for (var property in styles)
      if (property == 'opacity') element.setOpacity(styles[property])
      else
        elementStyle[(property == 'float' || property == 'cssFloat') ?
          (elementStyle.styleFloat === undefined ? 'cssFloat' : 'styleFloat') :
            property] = styles[property];

    return element;
  },

  setOpacity: function(element, value) {
    element = $(element);
    element.style.opacity = (value == 1 || value === '') ? '' :
      (value < 0.00001) ? 0 : value;
    return element;
  },

  getDimensions: function(element) {
    element = $(element);
    var display = $(element).getStyle('display');
    if (display != 'none' && display != null) // Safari bug
      return {width: element.offsetWidth, height: element.offsetHeight};

    // All *Width and *Height properties give 0 on elements with display none,
    // so enable the element temporarily
    var els = element.style;
    var originalVisibility = els.visibility;
    var originalPosition = els.position;
    var originalDisplay = els.display;
    els.visibility = 'hidden';
    els.position = 'absolute';
    els.display = 'block';
    var originalWidth = element.clientWidth;
    var originalHeight = element.clientHeight;
    els.display = originalDisplay;
    els.position = originalPosition;
    els.visibility = originalVisibility;
    return {width: originalWidth, height: originalHeight};
  },

  makePositioned: function(element) {
    element = $(element);
    var pos = Element.getStyle(element, 'position');
    if (pos == 'static' || !pos) {
      element._madePositioned = true;
      element.style.position = 'relative';
      // Opera returns the offset relative to the positioning context, when an
      // element is position relative but top and left have not been defined
      if (window.opera) {
        element.style.top = 0;
        element.style.left = 0;
      }
    }
    return element;
  },

  undoPositioned: function(element) {
    element = $(element);
    if (element._madePositioned) {
      element._madePositioned = undefined;
      element.style.position =
        element.style.top =
        element.style.left =
        element.style.bottom =
        element.style.right = '';
    }
    return element;
  },

  makeClipping: function(element) {
    element = $(element);
    if (element._overflow) return element;
    element._overflow = element.style.overflow || 'auto';
    if ((Element.getStyle(element, 'overflow') || 'visible') != 'hidden')
      element.style.overflow = 'hidden';
    return element;
  },

  undoClipping: function(element) {
    element = $(element);
    if (!element._overflow) return element;
    element.style.overflow = element._overflow == 'auto' ? '' : element._overflow;
    element._overflow = null;
    return element;
  },

  cumulativeOffset: function(element) {
    var valueT = 0, valueL = 0;
    do {
      valueT += element.offsetTop  || 0;
      valueL += element.offsetLeft || 0;
      element = element.offsetParent;
    } while (element);
    return Element._returnOffset(valueL, valueT);
  },

  positionedOffset: function(element) {
    var valueT = 0, valueL = 0;
    do {
      valueT += element.offsetTop  || 0;
      valueL += element.offsetLeft || 0;
      element = element.offsetParent;
      if (element) {
        if (element.tagName == 'BODY') break;
        var p = Element.getStyle(element, 'position');
        if (p == 'relative' || p == 'absolute') break;
      }
    } while (element);
    return Element._returnOffset(valueL, valueT);
  },

  absolutize: function(element) {
    element = $(element);
    if (element.getStyle('position') == 'absolute') return;
    // Position.prepare(); // To be done manually by Scripty when it needs it.

    var offsets = element.positionedOffset();
    var top     = offsets[1];
    var left    = offsets[0];
    var width   = element.clientWidth;
    var height  = element.clientHeight;

    element._originalLeft   = left - parseFloat(element.style.left  || 0);
    element._originalTop    = top  - parseFloat(element.style.top || 0);
    element._originalWidth  = element.style.width;
    element._originalHeight = element.style.height;

    element.style.position = 'absolute';
    element.style.top    = top + 'px';
    element.style.left   = left + 'px';
    element.style.width  = width + 'px';
    element.style.height = height + 'px';
    return element;
  },

  relativize: function(element) {
    element = $(element);
    if (element.getStyle('position') == 'relative') return;
    // Position.prepare(); // To be done manually by Scripty when it needs it.

    element.style.position = 'relative';
    var top  = parseFloat(element.style.top  || 0) - (element._originalTop || 0);
    var left = parseFloat(element.style.left || 0) - (element._originalLeft || 0);

    element.style.top    = top + 'px';
    element.style.left   = left + 'px';
    element.style.height = element._originalHeight;
    element.style.width  = element._originalWidth;
    return element;
  },

  cumulativeScrollOffset: function(element) {
    var valueT = 0, valueL = 0;
    do {
      valueT += element.scrollTop  || 0;
      valueL += element.scrollLeft || 0;
      element = element.parentNode;
    } while (element);
    return Element._returnOffset(valueL, valueT);
  },

  getOffsetParent: function(element) {
    if (element.offsetParent) return $(element.offsetParent);
    if (element == document.body) return $(element);

    while ((element = element.parentNode) && element != document.body)
      if (Element.getStyle(element, 'position') != 'static')
        return $(element);

    return $(document.body);
  },

  viewportOffset: function(forElement) {
    var valueT = 0, valueL = 0;

    var element = forElement;
    do {
      valueT += element.offsetTop  || 0;
      valueL += element.offsetLeft || 0;

      // Safari fix
      if (element.offsetParent == document.body &&
        Element.getStyle(element, 'position') == 'absolute') break;

    } while (element = element.offsetParent);

    element = forElement;
    do {
      if (!Prototype.Browser.Opera || element.tagName == 'BODY') {
        valueT -= element.scrollTop  || 0;
        valueL -= element.scrollLeft || 0;
      }
    } while (element = element.parentNode);

    return Element._returnOffset(valueL, valueT);
  },

  clonePosition: function(element, source) {
    var options = Object.extend({
      setLeft:    true,
      setTop:     true,
      setWidth:   true,
      setHeight:  true,
      offsetTop:  0,
      offsetLeft: 0
    }, arguments[2] || {});

    // find page position of source
    source = $(source);
    var p = source.viewportOffset();

    // find coordinate system to use
    element = $(element);
    var delta = [0, 0];
    var parent = null;
    // delta [0,0] will do fine with position: fixed elements,
    // position:absolute needs offsetParent deltas
    if (Element.getStyle(element, 'position') == 'absolute') {
      parent = element.getOffsetParent();
      delta = parent.viewportOffset();
    }

    // correct by body offsets (fixes Safari)
    if (parent == document.body) {
      delta[0] -= document.body.offsetLeft;
      delta[1] -= document.body.offsetTop;
    }

    // set position
    if (options.setLeft)   element.style.left  = (p[0] - delta[0] + options.offsetLeft) + 'px';
    if (options.setTop)    element.style.top   = (p[1] - delta[1] + options.offsetTop) + 'px';
    if (options.setWidth)  element.style.width = source.offsetWidth + 'px';
    if (options.setHeight) element.style.height = source.offsetHeight + 'px';
    return element;
  }
};

Element.Methods.identify.counter = 1;

if (!document.getElementsByClassName) document.getElementsByClassName = function(instanceMethods){
  function iter(name) {
    return name.blank() ? null : "[contains(concat(' ', @class, ' '), ' " + name + " ')]";
  }

  instanceMethods.getElementsByClassName = Prototype.BrowserFeatures.XPath ?
  function(element, className) {
    className = className.toString().strip();
    var cond = /\s/.test(className) ? $w(className).map(iter).join('') : iter(className);
    return cond ? document._getElementsByXPath('.//*' + cond, element) : [];
  } : function(element, className) {
    className = className.toString().strip();
    var elements = [], classNames = (/\s/.test(className) ? $w(className) : null);
    if (!classNames && !className) return elements;

    var nodes = $(element).getElementsByTagName('*');
    className = ' ' + className + ' ';

    for (var i = 0, child, cn; child = nodes[i]; i++) {
      if (child.className && (cn = ' ' + child.className + ' ') && (cn.include(className) ||
          (classNames && classNames.all(function(name) {
            return !name.toString().blank() && cn.include(' ' + name + ' ');
          }))))
        elements.push(Element.extend(child));
    }
    return elements;
  };

  return function(className, parentElement) {
    return $(parentElement || document.body).getElementsByClassName(className);
  };
}(Element.Methods);

Object.extend(Element.Methods, {
  getElementsBySelector: Element.Methods.select,
  childElements: Element.Methods.immediateDescendants
});

Element._attributeTranslations = {
  write: {
    names: {
      className: 'class',
      htmlFor:   'for'
    },
    values: {}
  }
};


if (!document.createRange || Prototype.Browser.Opera) {
  Element.Methods.insert = function(element, insertions) {
    element = $(element);

    if (typeof insertions == 'string' || typeof insertions == 'number' ||
        Object.isElement(insertions) || (insertions && (insertions.toElement || insertions.toHTML)))
          insertions = {bottom:insertions};

    var t = Element._insertionTranslations, content, position, pos, tagName;

    for (position in insertions) {
      content  = insertions[position];
      position = position.toLowerCase();
      pos      = t[position];

      if (content && content.toElement) content = content.toElement();
      if (Object.isElement(content)) {
        pos.insert(element, content);
        continue;
      }

      content = Object.toHTML(content);
      tagName = ((position == 'before' || position == 'after')
        ? element.parentNode : element).tagName.toUpperCase();

      if (t.tags[tagName]) {
        var fragments = Element._getContentFromAnonymousElement(tagName, content.stripScripts());
        if (position == 'top' || position == 'after') fragments.reverse();
        fragments.each(pos.insert.curry(element));
      }
      else element.insertAdjacentHTML(pos.adjacency, content.stripScripts());

      content.evalScripts.bind(content).defer();
    }

    return element;
  }
}

if (Prototype.Browser.Opera) {
  Element.Methods._getStyle = Element.Methods.getStyle;
  Element.Methods.getStyle = function(element, style) {
    switch(style) {
      case 'left':
      case 'top':
      case 'right':
      case 'bottom':
        if (Element._getStyle(element, 'position') == 'static') return null;
      default: return Element._getStyle(element, style);
    }
  };
  Element.Methods._readAttribute = Element.Methods.readAttribute;
  Element.Methods.readAttribute = function(element, attribute) {
    if (attribute == 'title') return element.title;
    return Element._readAttribute(element, attribute);
  };
}

else if (Prototype.Browser.IE) {
  Element.Methods.getStyle = function(element, style) {
    element = $(element);
    style = (style == 'float' || style == 'cssFloat') ? 'styleFloat' : style.camelize();
    var value = element.style[style];
    if (!value && element.currentStyle) value = element.currentStyle[style];

    if (style == 'opacity') {
      if (value = (element.getStyle('filter') || '').match(/alpha\(opacity=(.*)\)/))
        if (value[1]) return parseFloat(value[1]) / 100;
      return 1.0;
    }

    if (value == 'auto') {
      if ((style == 'width' || style == 'height') && (element.getStyle('display') != 'none'))
        return element['offset' + style.capitalize()] + 'px';
      return null;
    }
    return value;
  };

  Element.Methods.setOpacity = function(element, value) {
    function stripAlpha(filter){
      return filter.replace(/alpha\([^\)]*\)/gi,'');
    }
    element = $(element);
    var filter = element.getStyle('filter'), style = element.style;
    if (value == 1 || value === '') {
      (filter = stripAlpha(filter)) ?
        style.filter = filter : style.removeAttribute('filter');
      return element;
    } else if (value < 0.00001) value = 0;
    style.filter = stripAlpha(filter) +
      'alpha(opacity=' + (value * 100) + ')';
    return element;
  };

  Element._attributeTranslations = {
    read: {
      names: {
        'class': 'className',
        'for':   'htmlFor'
      },
      values: {
        _getAttr: function(element, attribute) {
          return element.getAttribute(attribute, 2);
        },
        _getEv: function(element, attribute) {
          var attribute = element.getAttribute(attribute);
          return attribute ? attribute.toString().slice(23, -2) : null;
        },
        _flag: function(element, attribute) {
          return $(element).hasAttribute(attribute) ? attribute : null;
        },
        style: function(element) {
          return element.style.cssText.toLowerCase();
        },
        title: function(element) {
          return element.title;
        }
      }
    }
  };

  Element._attributeTranslations.write = {
    names: Object.extend({
      colspan:   'colSpan',
      rowspan:   'rowSpan',
      valign:    'vAlign',
      datetime:  'dateTime',
      accesskey: 'accessKey',
      tabindex:  'tabIndex',
      enctype:   'encType',
      maxlength: 'maxLength',
      readonly:  'readOnly',
      longdesc:  'longDesc'
    }, Element._attributeTranslations.read.names),

    values: {
      checked: function(element, value) {
        element.checked = !!value;
      },

      style: function(element, value) {
        element.style.cssText = value ? value : '';
      }
    }
  };

  (function(v) {
    Object.extend(v, {
      href: v._getAttr,
      src:  v._getAttr,
      type: v._getAttr,
      disabled: v._flag,
      checked:  v._flag,
      readonly: v._flag,
      multiple: v._flag,
      onload:      v._getEv,
      onunload:    v._getEv,
      onclick:     v._getEv,
      ondblclick:  v._getEv,
      onmousedown: v._getEv,
      onmouseup:   v._getEv,
      onmouseover: v._getEv,
      onmousemove: v._getEv,
      onmouseout:  v._getEv,
      onfocus:     v._getEv,
      onblur:      v._getEv,
      onkeypress:  v._getEv,
      onkeydown:   v._getEv,
      onkeyup:     v._getEv,
      onsubmit:    v._getEv,
      onreset:     v._getEv,
      onselect:    v._getEv,
      onchange:    v._getEv
    });
  })(Element._attributeTranslations.read.values);
}

else if (Prototype.Browser.Gecko) {
  Element.Methods.setOpacity = function(element, value) {
    element = $(element);
    element.style.opacity = (value == 1) ? 0.999999 :
      (value === '') ? '' : (value < 0.00001) ? 0 : value;
    return element;
  };
}

else if (Prototype.Browser.WebKit) {
  Element.Methods.setOpacity = function(element, value) {
    element = $(element);
    element.style.opacity = (value == 1 || value === '') ? '' :
      (value < 0.00001) ? 0 : value;

    if (value == 1)
      if(element.tagName == 'IMG' && element.width) {
        element.width++; element.width--;
      } else try {
        var n = document.createTextNode(' ');
        element.appendChild(n);
        element.removeChild(n);
      } catch (e) {}

    return element;
  }

  // Safari returns margins on body which is incorrect if the child is absolutely
  // positioned.  For performance reasons, redefine Position.cumulativeOffset for
  // KHTML/WebKit only.
  Element.Methods.cumulativeOffset = function(element) {
    var valueT = 0, valueL = 0;
    do {
      valueT += element.offsetTop  || 0;
      valueL += element.offsetLeft || 0;
      if (element.offsetParent == document.body)
        if (Element.getStyle(element, 'position') == 'absolute') break;

      element = element.offsetParent;
    } while (element);

    return [valueL, valueT];
  }
}

if (Prototype.Browser.IE || Prototype.Browser.Opera) {
  // IE and Opera are missing .innerHTML support for TABLE-related and SELECT elements
  Element.Methods.update = function(element, content) {
    element = $(element);

    if (content && content.toElement) content = content.toElement();
    if (Object.isElement(content)) return element.update().insert(content);

    content = Object.toHTML(content);
    var tagName = element.tagName.toUpperCase();

    if (tagName in Element._insertionTranslations.tags) {
      $A(element.childNodes).each(function(node) { element.removeChild(node) });
      Element._getContentFromAnonymousElement(tagName, content.stripScripts())
        .each(function(node) { element.appendChild(node) });
    }
    else element.innerHTML = content.stripScripts();

    content.evalScripts.bind(content).defer();
    return element;
  };
}

if (document.createElement('div').outerHTML) {
  Element.Methods.replace = function(element, content) {
    element = $(element);

    if (content && content.toElement) content = content.toElement();
    if (Object.isElement(content)) {
      element.parentNode.replaceChild(content, element);
      return element;
    }

    content = Object.toHTML(content);
    var parent = element.parentNode, tagName = parent.tagName.toUpperCase();

    if (Element._insertionTranslations.tags[tagName]) {
      var nextSibling = element.next();
      var fragments = Element._getContentFromAnonymousElement(tagName, content.stripScripts());
      parent.removeChild(element);
      if (nextSibling)
        fragments.each(function(node) { parent.insertBefore(node, nextSibling) });
      else
        fragments.each(function(node) { parent.appendChild(node) });
    }
    else element.outerHTML = content.stripScripts();

    content.evalScripts.bind(content).defer();
    return element;
  };
}

Element._returnOffset = function(l, t) {
  var result = [l, t];
  result.left = l;
  result.top = t;
  return result;
};

Element._getContentFromAnonymousElement = function(tagName, html) {
  var div = new Element('div'); t = Element._insertionTranslations.tags[tagName]
  div.innerHTML = t[0] + html + t[1];
  t[2].times(function() { div = div.firstChild });
  return $A(div.childNodes);
};

Element._insertionTranslations = {
  before: {
    adjacency: 'beforeBegin',
    insert: function(element, node) {
      element.parentNode.insertBefore(node, element);
    },
    initializeRange: function(element, range) {
      range.setStartBefore(element);
    }
  },
  top: {
    adjacency: 'afterBegin',
    insert: function(element, node) {
      element.insertBefore(node, element.firstChild);
    },
    initializeRange: function(element, range) {
      range.selectNodeContents(element);
      range.collapse(true);
    }
  },
  bottom: {
    adjacency: 'beforeEnd',
    insert: function(element, node) {
      element.appendChild(node);
    }
  },
  after: {
    adjacency: 'afterEnd',
    insert: function(element, node) {
      element.parentNode.insertBefore(node, element.nextSibling);
    },
    initializeRange: function(element, range) {
      range.setStartAfter(element);
    }
  },
  tags: {
    TABLE:  ['<table>',                '</table>',                   1],
    TBODY:  ['<table><tbody>',         '</tbody></table>',           2],
    TR:     ['<table><tbody><tr>',     '</tr></tbody></table>',      3],
    TD:     ['<table><tbody><tr><td>', '</td></tr></tbody></table>', 4],
    SELECT: ['<select>',               '</select>',                  1]
  }
};

(function() {
  this.bottom.initializeRange = this.top.initializeRange;
  Object.extend(this.tags, {
    THEAD: this.tags.TBODY,
    TFOOT: this.tags.TBODY,
    TH:    this.tags.TD
  });
}).call(Element._insertionTranslations);

Element.Methods.Simulated = {
  hasAttribute: function(element, attribute) {
    var t = Element._attributeTranslations.read, node;
    attribute = t.names[attribute] || attribute;
    node = $(element).getAttributeNode(attribute);
    return node && node.specified;
  }
};

Element.Methods.ByTag = {};

Object.extend(Element, Element.Methods);

if (!Prototype.BrowserFeatures.ElementExtensions &&
    document.createElement('div').__proto__) {
  window.HTMLElement = {};
  window.HTMLElement.prototype = document.createElement('div').__proto__;
  Prototype.BrowserFeatures.ElementExtensions = true;
}

Element.extend = (function() {
  if (Prototype.BrowserFeatures.SpecificElementExtensions)
    return Prototype.K;

  var Methods = {}, ByTag = Element.Methods.ByTag;

  var extend = Object.extend(function(element) {
    if (!element || element._extendedByPrototype ||
        element.nodeType != 1 || element == window) return element;

    var methods = Object.clone(Methods),
      tagName = element.tagName, property, value;

    // extend methods for specific tags
    if (ByTag[tagName]) Object.extend(methods, ByTag[tagName]);

    for (property in methods) {
      value = methods[property];
      if (typeof value == 'function' && !(property in element))
        element[property] = value.methodize();
    }

    element._extendedByPrototype = Prototype.emptyFunction;
    return element;

  }, {
    refresh: function() {
      // extend methods for all tags (Safari doesn't need this)
      if (!Prototype.BrowserFeatures.ElementExtensions) {
        Object.extend(Methods, Element.Methods);
        Object.extend(Methods, Element.Methods.Simulated);
      }
    }
  });

  extend.refresh();
  return extend;
})();

Element.hasAttribute = function(element, attribute) {
  if (element.hasAttribute) return element.hasAttribute(attribute);
  return Element.Methods.Simulated.hasAttribute(element, attribute);
};

Element.addMethods = function(methods) {
  var F = Prototype.BrowserFeatures, T = Element.Methods.ByTag;

  if (!methods) {
    Object.extend(Form, Form.Methods);
    Object.extend(Form.Element, Form.Element.Methods);
    Object.extend(Element.Methods.ByTag, {
      "FORM":     Object.clone(Form.Methods),
      "INPUT":    Object.clone(Form.Element.Methods),
      "SELECT":   Object.clone(Form.Element.Methods),
      "TEXTAREA": Object.clone(Form.Element.Methods)
    });
  }

  if (arguments.length == 2) {
    var tagName = methods;
    methods = arguments[1];
  }

  if (!tagName) Object.extend(Element.Methods, methods || {});
  else {
    if (Object.isArray(tagName)) tagName.each(extend);
    else extend(tagName);
  }

  function extend(tagName) {
    tagName = tagName.toUpperCase();
    if (!Element.Methods.ByTag[tagName])
      Element.Methods.ByTag[tagName] = {};
    Object.extend(Element.Methods.ByTag[tagName], methods);
  }

  function copy(methods, destination, onlyIfAbsent) {
    onlyIfAbsent = onlyIfAbsent || false;
    for (var property in methods) {
      var value = methods[property];
      if (typeof value != 'function') continue;
      if (!onlyIfAbsent || !(property in destination))
        destination[property] = value.methodize();
    }
  }

  function findDOMClass(tagName) {
    var klass;
    var trans = {
      "OPTGROUP": "OptGroup", "TEXTAREA": "TextArea", "P": "Paragraph",
      "FIELDSET": "FieldSet", "UL": "UList", "OL": "OList", "DL": "DList",
      "DIR": "Directory", "H1": "Heading", "H2": "Heading", "H3": "Heading",
      "H4": "Heading", "H5": "Heading", "H6": "Heading", "Q": "Quote",
      "INS": "Mod", "DEL": "Mod", "A": "Anchor", "IMG": "Image", "CAPTION":
      "TableCaption", "COL": "TableCol", "COLGROUP": "TableCol", "THEAD":
      "TableSection", "TFOOT": "TableSection", "TBODY": "TableSection", "TR":
      "TableRow", "TH": "TableCell", "TD": "TableCell", "FRAMESET":
      "FrameSet", "IFRAME": "IFrame"
    };
    if (trans[tagName]) klass = 'HTML' + trans[tagName] + 'Element';
    if (window[klass]) return window[klass];
    klass = 'HTML' + tagName + 'Element';
    if (window[klass]) return window[klass];
    klass = 'HTML' + tagName.capitalize() + 'Element';
    if (window[klass]) return window[klass];

    window[klass] = {};
    window[klass].prototype = document.createElement(tagName).__proto__;
    return window[klass];
  }

  if (F.ElementExtensions) {
    copy(Element.Methods, HTMLElement.prototype);
    copy(Element.Methods.Simulated, HTMLElement.prototype, true);
  }

  if (F.SpecificElementExtensions) {
    for (var tag in Element.Methods.ByTag) {
      var klass = findDOMClass(tag);
      if (typeof klass == "undefined") continue;
      copy(T[tag], klass.prototype);
    }
  }

  Object.extend(Element, Element.Methods);
  delete Element.ByTag;

  if (Element.extend.refresh) Element.extend.refresh();
  Element.cache = {};
};
/* Portions of the Selector class are derived from Jack Slocum’s DomQuery,
 * part of YUI-Ext version 0.40, distributed under the terms of an MIT-style
 * license.  Please see http://www.yui-ext.com/ for more information. */

var Selector = Class.create();

Selector.prototype = {
  initialize: function(expression) {
    this.expression = expression.strip();
    this.compileMatcher();
  },

  compileMatcher: function() {
    // Selectors with namespaced attributes can't use the XPath version
    if (Prototype.BrowserFeatures.XPath && !(/\[[\w-]*?:/).test(this.expression))
      return this.compileXPathMatcher();

    var e = this.expression, ps = Selector.patterns, h = Selector.handlers,
        c = Selector.criteria, le, p, m;

    if (Selector._cache[e]) {
      this.matcher = Selector._cache[e]; return;
    }
    this.matcher = ["this.matcher = function(root) {",
                    "var r = root, h = Selector.handlers, c = false, n;"];

    while (e && le != e && (/\S/).test(e)) {
      le = e;
      for (var i in ps) {
        p = ps[i];
        if (m = e.match(p)) {
          this.matcher.push(typeof c[i] == 'function' ? c[i](m) :
    	      new Template(c[i]).evaluate(m));
          e = e.replace(m[0], '');
          break;
        }
      }
    }

    this.matcher.push("return h.unique(n);\n}");
    eval(this.matcher.join('\n'));
    Selector._cache[this.expression] = this.matcher;
  },

  compileXPathMatcher: function() {
    var e = this.expression, ps = Selector.patterns,
        x = Selector.xpath, le,  m;

    if (Selector._cache[e]) {
      this.xpath = Selector._cache[e]; return;
    }

    this.matcher = ['.//*'];
    while (e && le != e && (/\S/).test(e)) {
      le = e;
      for (var i in ps) {
        if (m = e.match(ps[i])) {
          this.matcher.push(typeof x[i] == 'function' ? x[i](m) :
            new Template(x[i]).evaluate(m));
          e = e.replace(m[0], '');
          break;
        }
      }
    }

    this.xpath = this.matcher.join('');
    Selector._cache[this.expression] = this.xpath;
  },

  findElements: function(root) {
    root = root || document;
    if (this.xpath) return document._getElementsByXPath(this.xpath, root);
    return this.matcher(root);
  },

  match: function(element) {
    this.tokens = [];

    var e = this.expression, ps = Selector.patterns, as = Selector.assertions;
    var le, p, m;

    while (e && le !== e && (/\S/).test(e)) {
      le = e;
      for (var i in ps) {
        p = ps[i];
        if (m = e.match(p)) {
          // use the Selector.assertions methods unless the selector
          // is too complex.
          if (as[i]) {
            this.tokens.push([i, Object.clone(m)]);
            e = e.replace(m[0], '');
          } else {
            // reluctantly do a document-wide search
            // and look for a match in the array
            return this.findElements(document).include(element);
          }
        }
      }
    }

    var match = true, name, matches;
    for (var i = 0, token; token = this.tokens[i]; i++) {
      name = token[0], matches = token[1];
      if (!Selector.assertions[name](element, matches)) {
        match = false; break;
      }
    }

    return match;
  },

  toString: function() {
    return this.expression;
  },

  inspect: function() {
    return "#<Selector:" + this.expression.inspect() + ">";
  }
};

Object.extend(Selector, {
  _cache: {},

  xpath: {
    descendant:   "//*",
    child:        "/*",
    adjacent:     "/following-sibling::*[1]",
    laterSibling: '/following-sibling::*',
    tagName:      function(m) {
      if (m[1] == '*') return '';
      return "[local-name()='" + m[1].toLowerCase() +
             "' or local-name()='" + m[1].toUpperCase() + "']";
    },
    className:    "[contains(concat(' ', @class, ' '), ' #{1} ')]",
    id:           "[@id='#{1}']",
    attrPresence: "[@#{1}]",
    attr: function(m) {
      m[3] = m[5] || m[6];
      return new Template(Selector.xpath.operators[m[2]]).evaluate(m);
    },
    pseudo: function(m) {
      var h = Selector.xpath.pseudos[m[1]];
      if (!h) return '';
      if (typeof h === 'function') return h(m);
      return new Template(Selector.xpath.pseudos[m[1]]).evaluate(m);
    },
    operators: {
      '=':  "[@#{1}='#{3}']",
      '!=': "[@#{1}!='#{3}']",
      '^=': "[starts-with(@#{1}, '#{3}')]",
      '$=': "[substring(@#{1}, (string-length(@#{1}) - string-length('#{3}') + 1))='#{3}']",
      '*=': "[contains(@#{1}, '#{3}')]",
      '~=': "[contains(concat(' ', @#{1}, ' '), ' #{3} ')]",
      '|=': "[contains(concat('-', @#{1}, '-'), '-#{3}-')]"
    },
    pseudos: {
      'first-child': '[not(preceding-sibling::*)]',
      'last-child':  '[not(following-sibling::*)]',
      'only-child':  '[not(preceding-sibling::* or following-sibling::*)]',
      'empty':       "[count(*) = 0 and (count(text()) = 0 or translate(text(), ' \t\r\n', '') = '')]",
      'checked':     "[@checked]",
      'disabled':    "[@disabled]",
      'enabled':     "[not(@disabled)]",
      'not': function(m) {
        var e = m[6], p = Selector.patterns,
            x = Selector.xpath, le, m, v;

        var exclusion = [];
        while (e && le != e && (/\S/).test(e)) {
          le = e;
          for (var i in p) {
            if (m = e.match(p[i])) {
              v = typeof x[i] == 'function' ? x[i](m) : new Template(x[i]).evaluate(m);
              exclusion.push("(" + v.substring(1, v.length - 1) + ")");
              e = e.replace(m[0], '');
              break;
            }
          }
        }
        return "[not(" + exclusion.join(" and ") + ")]";
      },
      'nth-child':      function(m) {
        return Selector.xpath.pseudos.nth("(count(./preceding-sibling::*) + 1) ", m);
      },
      'nth-last-child': function(m) {
        return Selector.xpath.pseudos.nth("(count(./following-sibling::*) + 1) ", m);
      },
      'nth-of-type':    function(m) {
        return Selector.xpath.pseudos.nth("position() ", m);
      },
      'nth-last-of-type': function(m) {
        return Selector.xpath.pseudos.nth("(last() + 1 - position()) ", m);
      },
      'first-of-type':  function(m) {
        m[6] = "1"; return Selector.xpath.pseudos['nth-of-type'](m);
      },
      'last-of-type':   function(m) {
        m[6] = "1"; return Selector.xpath.pseudos['nth-last-of-type'](m);
      },
      'only-of-type':   function(m) {
        var p = Selector.xpath.pseudos; return p['first-of-type'](m) + p['last-of-type'](m);
      },
      nth: function(fragment, m) {
        var mm, formula = m[6], predicate;
        if (formula == 'even') formula = '2n+0';
        if (formula == 'odd')  formula = '2n+1';
        if (mm = formula.match(/^(\d+)$/)) // digit only
          return '[' + fragment + "= " + mm[1] + ']';
        if (mm = formula.match(/^(-?\d*)?n(([+-])(\d+))?/)) { // an+b
          if (mm[1] == "-") mm[1] = -1;
          var a = mm[1] ? Number(mm[1]) : 1;
          var b = mm[2] ? Number(mm[2]) : 0;
          predicate = "[((#{fragment} - #{b}) mod #{a} = 0) and " +
          "((#{fragment} - #{b}) div #{a} >= 0)]";
          return new Template(predicate).evaluate({
            fragment: fragment, a: a, b: b });
        }
      }
    }
  },

  criteria: {
    tagName:      'n = h.tagName(n, r, "#{1}", c);   c = false;',
    className:    'n = h.className(n, r, "#{1}", c); c = false;',
    id:           'n = h.id(n, r, "#{1}", c);        c = false;',
    attrPresence: 'n = h.attrPresence(n, r, "#{1}"); c = false;',
    attr: function(m) {
      m[3] = (m[5] || m[6]);
      return new Template('n = h.attr(n, r, "#{1}", "#{3}", "#{2}"); c = false;').evaluate(m);
    },
    pseudo:       function(m) {
      if (m[6]) m[6] = m[6].replace(/"/g, '\\"');
      return new Template('n = h.pseudo(n, "#{1}", "#{6}", r, c); c = false;').evaluate(m);
    },
    descendant:   'c = "descendant";',
    child:        'c = "child";',
    adjacent:     'c = "adjacent";',
    laterSibling: 'c = "laterSibling";'
  },

  patterns: {
    // combinators must be listed first
    // (and descendant needs to be last combinator)
    laterSibling: /^\s*~\s*/,
    child:        /^\s*>\s*/,
    adjacent:     /^\s*\+\s*/,
    descendant:   /^\s/,

    // selectors follow
    tagName:      /^\s*(\*|[\w\-]+)(\b|$)?/,
    id:           /^#([\w\-\*]+)(\b|$)/,
    className:    /^\.([\w\-\*]+)(\b|$)/,
    pseudo:       /^:((first|last|nth|nth-last|only)(-child|-of-type)|empty|checked|(en|dis)abled|not)(\((.*?)\))?(\b|$|\s|(?=:))/,
    attrPresence: /^\[([\w]+)\]/,
    attr:         /\[((?:[\w-]*:)?[\w-]+)\s*(?:([!^$*~|]?=)\s*((['"])([^\]]*?)\4|([^'"][^\]]*?)))?\]/
  },

  // for Selector.match and Element#match
  assertions: {
    tagName: function(element, matches) {
      return matches[1].toUpperCase() == element.tagName.toUpperCase();
    },

    className: function(element, matches) {
      return Element.hasClassName(element, matches[1]);
    },

    id: function(element, matches) {
      return element.id === matches[1];
    },

    attrPresence: function(element, matches) {
      return Element.hasAttribute(element, matches[1]);
    },

    attr: function(element, matches) {
      var nodeValue = Element.readAttribute(element, matches[1]);
      return Selector.operators[matches[2]](nodeValue, matches[3]);
    }
  },

  handlers: {
    // UTILITY FUNCTIONS
    // joins two collections
    concat: function(a, b) {
      for (var i = 0, node; node = b[i]; i++)
        a.push(node);
      return a;
    },

    // marks an array of nodes for counting
    mark: function(nodes) {
      for (var i = 0, node; node = nodes[i]; i++)
        node._counted = true;
      return nodes;
    },

    unmark: function(nodes) {
      for (var i = 0, node; node = nodes[i]; i++)
        node._counted = undefined;
      return nodes;
    },

    // mark each child node with its position (for nth calls)
    // "ofType" flag indicates whether we're indexing for nth-of-type
    // rather than nth-child
    index: function(parentNode, reverse, ofType) {
      parentNode._counted = true;
      if (reverse) {
        for (var nodes = parentNode.childNodes, i = nodes.length - 1, j = 1; i >= 0; i--) {
          node = nodes[i];
          if (node.nodeType == 1 && (!ofType || node._counted)) node.nodeIndex = j++;
        }
      } else {
        for (var i = 0, j = 1, nodes = parentNode.childNodes; node = nodes[i]; i++)
          if (node.nodeType == 1 && (!ofType || node._counted)) node.nodeIndex = j++;
      }
    },

    // filters out duplicates and extends all nodes
    unique: function(nodes) {
      if (nodes.length == 0) return nodes;
      var results = [], n;
      for (var i = 0, l = nodes.length; i < l; i++)
        if (!(n = nodes[i])._counted) {
          n._counted = true;
          results.push(Element.extend(n));
        }
      return Selector.handlers.unmark(results);
    },

    // COMBINATOR FUNCTIONS
    descendant: function(nodes) {
      var h = Selector.handlers;
      for (var i = 0, results = [], node; node = nodes[i]; i++)
        h.concat(results, node.getElementsByTagName('*'));
      return results;
    },

    child: function(nodes) {
      var h = Selector.handlers;
      for (var i = 0, results = [], node; node = nodes[i]; i++) {
        for (var j = 0, children = [], child; child = node.childNodes[j]; j++)
          if (child.nodeType == 1 && child.tagName != '!') results.push(child);
      }
      return results;
    },

    adjacent: function(nodes) {
      for (var i = 0, results = [], node; node = nodes[i]; i++) {
        var next = this.nextElementSibling(node);
        if (next) results.push(next);
      }
      return results;
    },

    laterSibling: function(nodes) {
      var h = Selector.handlers;
      for (var i = 0, results = [], node; node = nodes[i]; i++)
        h.concat(results, Element.nextSiblings(node));
      return results;
    },

    nextElementSibling: function(node) {
      while (node = node.nextSibling)
	      if (node.nodeType == 1) return node;
      return null;
    },

    previousElementSibling: function(node) {
      while (node = node.previousSibling)
        if (node.nodeType == 1) return node;
      return null;
    },

    // TOKEN FUNCTIONS
    tagName: function(nodes, root, tagName, combinator) {
      tagName = tagName.toUpperCase();
      var results = [], h = Selector.handlers;
      if (nodes) {
        if (combinator) {
          // fastlane for ordinary descendant combinators
          if (combinator == "descendant") {
            for (var i = 0, node; node = nodes[i]; i++)
              h.concat(results, node.getElementsByTagName(tagName));
            return results;
          } else nodes = this[combinator](nodes);
          if (tagName == "*") return nodes;
        }
        for (var i = 0, node; node = nodes[i]; i++)
          if (node.tagName.toUpperCase() == tagName) results.push(node);
        return results;
      } else return root.getElementsByTagName(tagName);
    },

    id: function(nodes, root, id, combinator) {
      var targetNode = $(id), h = Selector.handlers;
      if (!targetNode) return [];
      if (!nodes && root == document) return [targetNode];
      if (nodes) {
        if (combinator) {
          if (combinator == 'child') {
            for (var i = 0, node; node = nodes[i]; i++)
              if (targetNode.parentNode == node) return [targetNode];
          } else if (combinator == 'descendant') {
            for (var i = 0, node; node = nodes[i]; i++)
              if (Element.descendantOf(targetNode, node)) return [targetNode];
          } else if (combinator == 'adjacent') {
            for (var i = 0, node; node = nodes[i]; i++)
              if (Selector.handlers.previousElementSibling(targetNode) == node)
                return [targetNode];
          } else nodes = h[combinator](nodes);
        }
        for (var i = 0, node; node = nodes[i]; i++)
          if (node == targetNode) return [targetNode];
        return [];
      }
      return (targetNode && Element.descendantOf(targetNode, root)) ? [targetNode] : [];
    },

    className: function(nodes, root, className, combinator) {
      if (nodes && combinator) nodes = this[combinator](nodes);
      return Selector.handlers.byClassName(nodes, root, className);
    },

    byClassName: function(nodes, root, className) {
      if (!nodes) nodes = Selector.handlers.descendant([root]);
      var needle = ' ' + className + ' ';
      for (var i = 0, results = [], node, nodeClassName; node = nodes[i]; i++) {
        nodeClassName = node.className;
        if (nodeClassName.length == 0) continue;
        if (nodeClassName == className || (' ' + nodeClassName + ' ').include(needle))
          results.push(node);
      }
      return results;
    },

    attrPresence: function(nodes, root, attr) {
      var results = [];
      for (var i = 0, node; node = nodes[i]; i++)
        if (Element.hasAttribute(node, attr)) results.push(node);
      return results;
    },

    attr: function(nodes, root, attr, value, operator) {
      if (!nodes) nodes = root.getElementsByTagName("*");
      var handler = Selector.operators[operator], results = [];
      for (var i = 0, node; node = nodes[i]; i++) {
        var nodeValue = Element.readAttribute(node, attr);
        if (nodeValue === null) continue;
        if (handler(nodeValue, value)) results.push(node);
      }
      return results;
    },

    pseudo: function(nodes, name, value, root, combinator) {
      if (nodes && combinator) nodes = this[combinator](nodes);
      if (!nodes) nodes = root.getElementsByTagName("*");
      return Selector.pseudos[name](nodes, value, root);
    }
  },

  pseudos: {
    'first-child': function(nodes, value, root) {
      for (var i = 0, results = [], node; node = nodes[i]; i++) {
        if (Selector.handlers.previousElementSibling(node)) continue;
          results.push(node);
      }
      return results;
    },
    'last-child': function(nodes, value, root) {
      for (var i = 0, results = [], node; node = nodes[i]; i++) {
        if (Selector.handlers.nextElementSibling(node)) continue;
          results.push(node);
      }
      return results;
    },
    'only-child': function(nodes, value, root) {
      var h = Selector.handlers;
      for (var i = 0, results = [], node; node = nodes[i]; i++)
        if (!h.previousElementSibling(node) && !h.nextElementSibling(node))
          results.push(node);
      return results;
    },
    'nth-child':        function(nodes, formula, root) {
      return Selector.pseudos.nth(nodes, formula, root);
    },
    'nth-last-child':   function(nodes, formula, root) {
      return Selector.pseudos.nth(nodes, formula, root, true);
    },
    'nth-of-type':      function(nodes, formula, root) {
      return Selector.pseudos.nth(nodes, formula, root, false, true);
    },
    'nth-last-of-type': function(nodes, formula, root) {
      return Selector.pseudos.nth(nodes, formula, root, true, true);
    },
    'first-of-type':    function(nodes, formula, root) {
      return Selector.pseudos.nth(nodes, "1", root, false, true);
    },
    'last-of-type':     function(nodes, formula, root) {
      return Selector.pseudos.nth(nodes, "1", root, true, true);
    },
    'only-of-type':     function(nodes, formula, root) {
      var p = Selector.pseudos;
      return p['last-of-type'](p['first-of-type'](nodes, formula, root), formula, root);
    },

    // handles the an+b logic
    getIndices: function(a, b, total) {
      if (a == 0) return b > 0 ? [b] : [];
      return $R(1, total).inject([], function(memo, i) {
        if (0 == (i - b) % a && (i - b) / a >= 0) memo.push(i);
        return memo;
      });
    },

    // handles nth(-last)-child, nth(-last)-of-type, and (first|last)-of-type
    nth: function(nodes, formula, root, reverse, ofType) {
      if (nodes.length == 0) return [];
      if (formula == 'even') formula = '2n+0';
      if (formula == 'odd')  formula = '2n+1';
      var h = Selector.handlers, results = [], indexed = [], m;
      h.mark(nodes);
      for (var i = 0, node; node = nodes[i]; i++) {
        if (!node.parentNode._counted) {
          h.index(node.parentNode, reverse, ofType);
          indexed.push(node.parentNode);
        }
      }
      if (formula.match(/^\d+$/)) { // just a number
        formula = Number(formula);
        for (var i = 0, node; node = nodes[i]; i++)
          if (node.nodeIndex == formula) results.push(node);
      } else if (m = formula.match(/^(-?\d*)?n(([+-])(\d+))?/)) { // an+b
        if (m[1] == "-") m[1] = -1;
        var a = m[1] ? Number(m[1]) : 1;
        var b = m[2] ? Number(m[2]) : 0;
        var indices = Selector.pseudos.getIndices(a, b, nodes.length);
        for (var i = 0, node, l = indices.length; node = nodes[i]; i++) {
          for (var j = 0; j < l; j++)
            if (node.nodeIndex == indices[j]) results.push(node);
        }
      }
      h.unmark(nodes);
      h.unmark(indexed);
      return results;
    },

    'empty': function(nodes, value, root) {
      for (var i = 0, results = [], node; node = nodes[i]; i++) {
        // IE treats comments as element nodes
        if (node.tagName == '!' || (node.firstChild && !node.innerHTML.match(/^\s*$/))) continue;
        results.push(node);
      }
      return results;
    },

    'not': function(nodes, selector, root) {
      var h = Selector.handlers, selectorType, m;
      var exclusions = new Selector(selector).findElements(root);
      h.mark(exclusions);
      for (var i = 0, results = [], node; node = nodes[i]; i++)
        if (!node._counted) results.push(node);
      h.unmark(exclusions);
      return results;
    },

    'enabled': function(nodes, value, root) {
      for (var i = 0, results = [], node; node = nodes[i]; i++)
        if (!node.disabled) results.push(node);
      return results;
    },

    'disabled': function(nodes, value, root) {
      for (var i = 0, results = [], node; node = nodes[i]; i++)
        if (node.disabled) results.push(node);
      return results;
    },

    'checked': function(nodes, value, root) {
      for (var i = 0, results = [], node; node = nodes[i]; i++)
        if (node.checked) results.push(node);
      return results;
    }
  },

  operators: {
    '=':  function(nv, v) { return nv == v; },
    '!=': function(nv, v) { return nv != v; },
    '^=': function(nv, v) { return nv.startsWith(v); },
    '$=': function(nv, v) { return nv.endsWith(v); },
    '*=': function(nv, v) { return nv.include(v); },
    '~=': function(nv, v) { return (' ' + nv + ' ').include(' ' + v + ' '); },
    '|=': function(nv, v) { return ('-' + nv.toUpperCase() + '-').include('-' + v.toUpperCase() + '-'); }
  },

  matchElements: function(elements, expression) {
    var matches = new Selector(expression).findElements(), h = Selector.handlers;
    h.mark(matches);
    for (var i = 0, results = [], element; element = elements[i]; i++)
      if (element._counted) results.push(element);
    h.unmark(matches);
    return results;
  },

  findElement: function(elements, expression, index) {
    if (typeof expression == 'number') {
      index = expression; expression = false;
    }
    return Selector.matchElements(elements, expression || '*')[index || 0];
  },

  findChildElements: function(element, expressions) {
    var exprs = expressions.join(','), expressions = [];
    exprs.scan(/(([\w#:.~>+()\s-]+|\*|\[.*?\])+)\s*(,|$)/, function(m) {
      expressions.push(m[1].strip());
    });
    var results = [], h = Selector.handlers;
    for (var i = 0, l = expressions.length, selector; i < l; i++) {
      selector = new Selector(expressions[i].strip());
      h.concat(results, selector.findElements(element));
    }
    return (l > 1) ? h.unique(results) : results;
  }
});

function $$() {
  return Selector.findChildElements(document, $A(arguments));
}
var Form = {
  reset: function(form) {
    $(form).reset();
    return form;
  },

  serializeElements: function(elements, options) {
    if (typeof options != 'object') options = { hash: !!options };
    else if (options.hash === undefined) options.hash = true;
    var key, value, submitted = false, submit = options.submit;

    var data = elements.inject({}, function(result, element) {
      if (!element.disabled && element.name) {
        key = element.name; value = $(element).getValue();
        if (value != null && (element.type != 'submit' || (!submitted &&
            submit !== false && (!submit || key == submit) && (submitted = true)))) {
          if (key in result) {
            // a key is already present; construct an array of values
            if (!Object.isArray(result[key])) result[key] = [result[key]];
            result[key].push(value);
          }
          else result[key] = value;
        }
      }
      return result;
    });

    return options.hash ? data : Hash.toQueryString(data);
  }
};

Form.Methods = {
  serialize: function(form, options) {
    return Form.serializeElements(Form.getElements(form), options);
  },

  getElements: function(form) {
    return $A($(form).getElementsByTagName('*')).inject([],
      function(elements, child) {
        if (Form.Element.Serializers[child.tagName.toLowerCase()])
          elements.push(Element.extend(child));
        return elements;
      }
    );
  },

  getInputs: function(form, typeName, name) {
    form = $(form);
    var inputs = form.getElementsByTagName('input');

    if (!typeName && !name) return $A(inputs).map(Element.extend);

    for (var i = 0, matchingInputs = [], length = inputs.length; i < length; i++) {
      var input = inputs[i];
      if ((typeName && input.type != typeName) || (name && input.name != name))
        continue;
      matchingInputs.push(Element.extend(input));
    }

    return matchingInputs;
  },

  disable: function(form) {
    form = $(form);
    Form.getElements(form).invoke('disable');
    return form;
  },

  enable: function(form) {
    form = $(form);
    Form.getElements(form).invoke('enable');
    return form;
  },

  findFirstElement: function(form) {
    var elements = $(form).getElements().findAll(function(element) {
      return 'hidden' != element.type && !element.disabled;
    });
    var firstByIndex = elements.findAll(function(element) {
      return element.hasAttribute('tabIndex') && element.tabIndex >= 0;
    }).sortBy(function(element) { return element.tabIndex }).first();

    return firstByIndex ? firstByIndex : elements.find(function(element) {
      return ['input', 'select', 'textarea'].include(element.tagName.toLowerCase());
    });
  },

  focusFirstElement: function(form) {
    form = $(form);
    form.findFirstElement().activate();
    return form;
  },

  request: function(form, options) {
    form = $(form), options = Object.clone(options || {});

    var params = options.parameters, action = form.readAttribute('action') || '';
    if (action.blank()) action = window.location.href;
    options.parameters = form.serialize(true);

    if (params) {
      if (typeof params == 'string') params = params.toQueryParams();
      Object.extend(options.parameters, params);
    }

    if (form.hasAttribute('method') && !options.method)
      options.method = form.method;

    return new Ajax.Request(action, options);
  }
}

/*--------------------------------------------------------------------------*/

Form.Element = {
  focus: function(element) {
    $(element).focus();
    return element;
  },

  select: function(element) {
    $(element).select();
    return element;
  }
}

Form.Element.Methods = {
  serialize: function(element) {
    element = $(element);
    if (!element.disabled && element.name) {
      var value = element.getValue();
      if (value != undefined) {
        var pair = {};
        pair[element.name] = value;
        return Hash.toQueryString(pair);
      }
    }
    return '';
  },

  getValue: function(element) {
    element = $(element);
    var method = element.tagName.toLowerCase();
    return Form.Element.Serializers[method](element);
  },

  setValue: function(element, value) {
    element = $(element);
    var method = element.tagName.toLowerCase();
    Form.Element.Serializers[method](element, value);
    return element;
  },

  clear: function(element) {
    $(element).value = '';
    return element;
  },

  present: function(element) {
    return $(element).value != '';
  },

  activate: function(element) {
    element = $(element);
    try {
      element.focus();
      if (element.select && (element.tagName.toLowerCase() != 'input' ||
          !['button', 'reset', 'submit'].include(element.type)))
        element.select();
    } catch (e) {}
    return element;
  },

  disable: function(element) {
    element = $(element);
    element.blur();
    element.disabled = true;
    return element;
  },

  enable: function(element) {
    element = $(element);
    element.disabled = false;
    return element;
  }
}

/*--------------------------------------------------------------------------*/

var Field = Form.Element;
var $F = Form.Element.Methods.getValue;

/*--------------------------------------------------------------------------*/

Form.Element.Serializers = {
  input: function(element, value) {
    switch (element.type.toLowerCase()) {
      case 'checkbox':
      case 'radio':
        return Form.Element.Serializers.inputSelector(element, value);
      default:
        return Form.Element.Serializers.textarea(element, value);
    }
  },

  inputSelector: function(element, value) {
    if (value === undefined) return element.checked ? element.value : null;
    else element.checked = !!value;
  },

  textarea: function(element, value) {
    if (value === undefined) return element.value;
    else element.value = value;
  },

  select: function(element, index) {
    if (index === undefined)
      return this[element.type == 'select-one' ?
        'selectOne' : 'selectMany'](element);
    else {
      var opt, value, single = !Object.isArray(index);
      for (var i = 0, length = element.length; i < length; i++) {
        opt = element.options[i];
        value = this.optionValue(opt);
        if (single) {
          if (value == index) {
            opt.selected = true;
            return;
          }
        }
        else opt.selected = index.include(value);
      }
    }
  },

  selectOne: function(element) {
    var index = element.selectedIndex;
    return index >= 0 ? this.optionValue(element.options[index]) : null;
  },

  selectMany: function(element) {
    var values, length = element.length;
    if (!length) return null;

    for (var i = 0, values = []; i < length; i++) {
      var opt = element.options[i];
      if (opt.selected) values.push(this.optionValue(opt));
    }
    return values;
  },

  optionValue: function(opt) {
    // extend element because hasAttribute may not be native
    return Element.extend(opt).hasAttribute('value') ? opt.value : opt.text;
  }
}

/*--------------------------------------------------------------------------*/

Abstract.TimedObserver = function() {}
Abstract.TimedObserver.prototype = {
  initialize: function(element, frequency, callback) {
    this.frequency = frequency;
    this.element   = $(element);
    this.callback  = callback;

    this.lastValue = this.getValue();
    this.registerCallback();
  },

  registerCallback: function() {
    setInterval(this.onTimerEvent.bind(this), this.frequency * 1000);
  },

  onTimerEvent: function() {
    var value = this.getValue();
    var changed = ('string' == typeof this.lastValue && 'string' == typeof value
      ? this.lastValue != value : String(this.lastValue) != String(value));
    if (changed) {
      this.callback(this.element, value);
      this.lastValue = value;
    }
  }
}

Form.Element.Observer = Class.create();
Form.Element.Observer.prototype = Object.extend(new Abstract.TimedObserver(), {
  getValue: function() {
    return Form.Element.getValue(this.element);
  }
});

Form.Observer = Class.create();
Form.Observer.prototype = Object.extend(new Abstract.TimedObserver(), {
  getValue: function() {
    return Form.serialize(this.element);
  }
});

/*--------------------------------------------------------------------------*/

Abstract.EventObserver = function() {}
Abstract.EventObserver.prototype = {
  initialize: function(element, callback) {
    this.element  = $(element);
    this.callback = callback;

    this.lastValue = this.getValue();
    if (this.element.tagName.toLowerCase() == 'form')
      this.registerFormCallbacks();
    else
      this.registerCallback(this.element);
  },

  onElementEvent: function() {
    var value = this.getValue();
    if (this.lastValue != value) {
      this.callback(this.element, value);
      this.lastValue = value;
    }
  },

  registerFormCallbacks: function() {
    Form.getElements(this.element).each(this.registerCallback.bind(this));
  },

  registerCallback: function(element) {
    if (element.type) {
      switch (element.type.toLowerCase()) {
        case 'checkbox':
        case 'radio':
          Event.observe(element, 'click', this.onElementEvent.bind(this));
          break;
        default:
          Event.observe(element, 'change', this.onElementEvent.bind(this));
          break;
      }
    }
  }
}

Form.Element.EventObserver = Class.create();
Form.Element.EventObserver.prototype = Object.extend(new Abstract.EventObserver(), {
  getValue: function() {
    return Form.Element.getValue(this.element);
  }
});

Form.EventObserver = Class.create();
Form.EventObserver.prototype = Object.extend(new Abstract.EventObserver(), {
  getValue: function() {
    return Form.serialize(this.element);
  }
});
if (!window.Event) {
  var Event = new Object();
}

Object.extend(Event, {
  KEY_BACKSPACE: 8,
  KEY_TAB:       9,
  KEY_RETURN:   13,
  KEY_ESC:      27,
  KEY_LEFT:     37,
  KEY_UP:       38,
  KEY_RIGHT:    39,
  KEY_DOWN:     40,
  KEY_DELETE:   46,
  KEY_HOME:     36,
  KEY_END:      35,
  KEY_PAGEUP:   33,
  KEY_PAGEDOWN: 34,

  element: function(event) {
    return $(event.target || event.srcElement);
  },

  isLeftClick: function(event) {
    return (((event.which) && (event.which == 1)) ||
            ((event.button) && (event.button == 1)));
  },

  pointerX: function(event) {
    return event.pageX || (event.clientX +
      (document.documentElement.scrollLeft || document.body.scrollLeft));
  },

  pointerY: function(event) {
    return event.pageY || (event.clientY +
      (document.documentElement.scrollTop || document.body.scrollTop));
  },

  stop: function(event) {
    if (event.preventDefault) {
      event.preventDefault();
      event.stopPropagation();
    } else {
      event.returnValue = false;
      event.cancelBubble = true;
    }
  },

  findElement: function(event, expression) {
    var element = Event.element(event);
    return element.match(expression) ? element : element.up(expression);
  },

  observers: false,

  _observeAndCache: function(element, name, observer, useCapture) {
    if (!this.observers) this.observers = [];
    if (element.addEventListener) {
      this.observers.push([element, name, observer, useCapture]);
      element.addEventListener(name, observer, useCapture);
    } else if (element.attachEvent) {
      this.observers.push([element, name, observer, useCapture]);
      element.attachEvent('on' + name, observer);
    }
  },

  unloadCache: function() {
    if (!Event.observers) return;
    for (var i = 0, length = Event.observers.length; i < length; i++) {
      Event.stopObserving.apply(this, Event.observers[i]);
      Event.observers[i][0] = null;
    }
    Event.observers = false;
  },

  observe: function(element, name, observer, useCapture) {
    element = $(element);
    useCapture = useCapture || false;

    if (name == 'keypress' &&
      (Prototype.Browser.WebKit || element.attachEvent))
      name = 'keydown';

    Event._observeAndCache(element, name, observer, useCapture);
  },

  stopObserving: function(element, name, observer, useCapture) {
    element = $(element);
    useCapture = useCapture || false;

    if (name == 'keypress' &&
        (Prototype.Browser.WebKit || element.attachEvent))
      name = 'keydown';

    if (element.removeEventListener) {
      element.removeEventListener(name, observer, useCapture);
    } else if (element.detachEvent) {
      try {
        element.detachEvent('on' + name, observer);
      } catch (e) {}
    }
  }
});

/* prevent memory leaks in IE */
if (Prototype.Browser.IE)
  Event.observe(window, 'unload', Event.unloadCache, false);
/*------------------------------- DEPRECATED -------------------------------*/

var Toggle = { display: Element.toggle };

Element.Methods.childOf = Element.Methods.descendantOf;

var Insertion = {
  Before: function(element, content) {
    return Element.insert(element, {before:content});
  },

  Top: function(element, content) {
    return Element.insert(element, {top:content});
  },

  Bottom: function(element, content) {
    return Element.insert(element, {bottom:content});
  },

  After: function(element, content) {
    return Element.insert(element, {after:content});
  }
};

var $continue = new Error('"throw $continue" is deprecated, use "return" instead');

// This should be moved to script.aculo.us; notice the deprecated methods
// further below, that map to the newer Element methods.
var Position = {
  // set to true if needed, warning: firefox performance problems
  // NOT neeeded for page scrolling, only if draggable contained in
  // scrollable elements
  includeScrollOffsets: false,

  // must be called before calling withinIncludingScrolloffset, every time the
  // page is scrolled
  prepare: function() {
    this.deltaX =  window.pageXOffset
                || document.documentElement.scrollLeft
                || document.body.scrollLeft
                || 0;
    this.deltaY =  window.pageYOffset
                || document.documentElement.scrollTop
                || document.body.scrollTop
                || 0;
  },

  // caches x/y coordinate pair to use with overlap
  within: function(element, x, y) {
    if (this.includeScrollOffsets)
      return this.withinIncludingScrolloffsets(element, x, y);
    this.xcomp = x;
    this.ycomp = y;
    this.offset = Element.cumulativeOffset(element);

    return (y >= this.offset[1] &&
            y <  this.offset[1] + element.offsetHeight &&
            x >= this.offset[0] &&
            x <  this.offset[0] + element.offsetWidth);
  },

  withinIncludingScrolloffsets: function(element, x, y) {
    var offsetcache = Element.cumulativeScrollOffset(element);

    this.xcomp = x + offsetcache[0] - this.deltaX;
    this.ycomp = y + offsetcache[1] - this.deltaY;
    this.offset = Element.cumulativeOffset(element);

    return (this.ycomp >= this.offset[1] &&
            this.ycomp <  this.offset[1] + element.offsetHeight &&
            this.xcomp >= this.offset[0] &&
            this.xcomp <  this.offset[0] + element.offsetWidth);
  },

  // within must be called directly before
  overlap: function(mode, element) {
    if (!mode) return 0;
    if (mode == 'vertical')
      return ((this.offset[1] + element.offsetHeight) - this.ycomp) /
        element.offsetHeight;
    if (mode == 'horizontal')
      return ((this.offset[0] + element.offsetWidth) - this.xcomp) /
        element.offsetWidth;
  },

  // Deprecation layer -- use newer Element methods now (1.5.2).

  cumulativeOffset: Element.Methods.cumulativeOffset,

  positionedOffset: Element.Methods.positionedOffset,

  absolutize: function(element) {
    Position.prepare();
    return Element.absolutize(element);
  },

  relativize: function(element) {
    Position.prepare();
    return Element.relativize(element);
  },

  realOffset: Element.Methods.cumulativeScrollOffset,

  offsetParent: Element.Methods.getOffsetParent,

  page: Element.Methods.viewportOffset,

  clone: function(source, target, options) {
    options = options || {};
    return Element.clonePosition(target, source, options);
  }
};

/*--------------------------------------------------------------------------*/

Element.ClassNames = Class.create();
Element.ClassNames.prototype = {
  initialize: function(element) {
    this.element = $(element);
  },

  _each: function(iterator) {
    this.element.className.split(/\s+/).select(function(name) {
      return name.length > 0;
    })._each(iterator);
  },

  set: function(className) {
    this.element.className = className;
  },

  add: function(classNameToAdd) {
    if (this.include(classNameToAdd)) return;
    this.set($A(this).concat(classNameToAdd).join(' '));
  },

  remove: function(classNameToRemove) {
    if (!this.include(classNameToRemove)) return;
    this.set($A(this).without(classNameToRemove).join(' '));
  },

  toString: function() {
    return $A(this).join(' ');
  }
};

Object.extend(Element.ClassNames.prototype, Enumerable);

/*--------------------------------------------------------------------------*/

Element.addMethods();

// Copyright (c) 2005-2007 Thomas Fuchs (http://script.aculo.us, http://mir.aculo.us)
// Contributors:
//  Justin Palmer (http://encytemedia.com/)
//  Mark Pilgrim (http://diveintomark.org/)
//  Martin Bialasinki
// 
// script.aculo.us is freely distributable under the terms of an MIT-style license.
// For details, see the script.aculo.us web site: http://script.aculo.us/ 

// converts rgb() and #xxx to #xxxxxx format,  
// returns self (or first argument) if not convertable  
String.prototype.parseColor = function() {  
  var color = '#';
  if(this.slice(0,4) == 'rgb(') {  
    var cols = this.slice(4,this.length-1).split(',');  
    var i=0; do { color += parseInt(cols[i]).toColorPart() } while (++i<3);  
  } else {  
    if(this.slice(0,1) == '#') {  
      if(this.length==4) for(var i=1;i<4;i++) color += (this.charAt(i) + this.charAt(i)).toLowerCase();  
      if(this.length==7) color = this.toLowerCase();  
    }  
  }  
  return(color.length==7 ? color : (arguments[0] || this));  
}

/*--------------------------------------------------------------------------*/

Element.collectTextNodes = function(element) {  
  return $A($(element).childNodes).collect( function(node) {
    return (node.nodeType==3 ? node.nodeValue : 
      (node.hasChildNodes() ? Element.collectTextNodes(node) : ''));
  }).flatten().join('');
}

Element.collectTextNodesIgnoreClass = function(element, className) {  
  return $A($(element).childNodes).collect( function(node) {
    return (node.nodeType==3 ? node.nodeValue : 
      ((node.hasChildNodes() && !Element.hasClassName(node,className)) ? 
        Element.collectTextNodesIgnoreClass(node, className) : ''));
  }).flatten().join('');
}

Element.setContentZoom = function(element, percent) {
  element = $(element);  
  element.setStyle({fontSize: (percent/100) + 'em'});   
  if(Prototype.Browser.WebKit) window.scrollBy(0,0);
  return element;
}

Element.getInlineOpacity = function(element){
  return $(element).style.opacity || '';
}

Element.forceRerendering = function(element) {
  try {
    element = $(element);
    var n = document.createTextNode(' ');
    element.appendChild(n);
    element.removeChild(n);
  } catch(e) { }
};

/*--------------------------------------------------------------------------*/

Array.prototype.call = function() {
  var args = arguments;
  this.each(function(f){ f.apply(this, args) });
}

/*--------------------------------------------------------------------------*/

var Effect = {
  _elementDoesNotExistError: {
    name: 'ElementDoesNotExistError',
    message: 'The specified DOM element does not exist, but is required for this effect to operate'
  },
  tagifyText: function(element) {
    if(typeof Builder == 'undefined')
      throw("Effect.tagifyText requires including script.aculo.us' builder.js library");
      
    var tagifyStyle = 'position:relative';
    if(Prototype.Browser.IE) tagifyStyle += ';zoom:1';
    
    element = $(element);
    $A(element.childNodes).each( function(child) {
      if(child.nodeType==3) {
        child.nodeValue.toArray().each( function(character) {
          element.insertBefore(
            Builder.node('span',{style: tagifyStyle},
              character == ' ' ? String.fromCharCode(160) : character), 
              child);
        });
        Element.remove(child);
      }
    });
  },
  multiple: function(element, effect) {
    var elements;
    if(((typeof element == 'object') || 
        (typeof element == 'function')) && 
       (element.length))
      elements = element;
    else
      elements = $(element).childNodes;
      
    var options = Object.extend({
      speed: 0.1,
      delay: 0.0
    }, arguments[2] || {});
    var masterDelay = options.delay;

    $A(elements).each( function(element, index) {
      new effect(element, Object.extend(options, { delay: index * options.speed + masterDelay }));
    });
  },
  PAIRS: {
    'slide':  ['SlideDown','SlideUp'],
    'blind':  ['BlindDown','BlindUp'],
    'appear': ['Appear','Fade']
  },
  toggle: function(element, effect) {
    element = $(element);
    effect = (effect || 'appear').toLowerCase();
    var options = Object.extend({
      queue: { position:'end', scope:(element.id || 'global'), limit: 1 }
    }, arguments[2] || {});
    Effect[element.visible() ? 
      Effect.PAIRS[effect][1] : Effect.PAIRS[effect][0]](element, options);
  }
};

var Effect2 = Effect; // deprecated

/* ------------- transitions ------------- */

Effect.Transitions = {
  linear: Prototype.K,
  sinoidal: function(pos) {
    return (-Math.cos(pos*Math.PI)/2) + 0.5;
  },
  reverse: function(pos) {
    return 1-pos;
  },
  flicker: function(pos) {
    var pos = ((-Math.cos(pos*Math.PI)/4) + 0.75) + Math.random()/4;
    return (pos > 1 ? 1 : pos);
  },
  wobble: function(pos) {
    return (-Math.cos(pos*Math.PI*(9*pos))/2) + 0.5;
  },
  pulse: function(pos, pulses) { 
    pulses = pulses || 5; 
    return (
      Math.round((pos % (1/pulses)) * pulses) == 0 ? 
            ((pos * pulses * 2) - Math.floor(pos * pulses * 2)) : 
        1 - ((pos * pulses * 2) - Math.floor(pos * pulses * 2))
      );
  },
  none: function(pos) {
    return 0;
  },
  full: function(pos) {
    return 1;
  }
};

/* ------------- core effects ------------- */

Effect.ScopedQueue = Class.create();
Object.extend(Object.extend(Effect.ScopedQueue.prototype, Enumerable), {
  initialize: function() {
    this.effects  = [];
    this.interval = null;    
  },
  _each: function(iterator) {
    this.effects._each(iterator);
  },
  add: function(effect) {
    var timestamp = new Date().getTime();
    
    var position = (typeof effect.options.queue == 'string') ? 
      effect.options.queue : effect.options.queue.position;
    
    switch(position) {
      case 'front':
        // move unstarted effects after this effect  
        this.effects.findAll(function(e){ return e.state=='idle' }).each( function(e) {
            e.startOn  += effect.finishOn;
            e.finishOn += effect.finishOn;
          });
        break;
      case 'with-last':
        timestamp = this.effects.pluck('startOn').max() || timestamp;
        break;
      case 'end':
        // start effect after last queued effect has finished
        timestamp = this.effects.pluck('finishOn').max() || timestamp;
        break;
    }
    
    effect.startOn  += timestamp;
    effect.finishOn += timestamp;

    if(!effect.options.queue.limit || (this.effects.length < effect.options.queue.limit))
      this.effects.push(effect);
    
    if(!this.interval)
      this.interval = setInterval(this.loop.bind(this), 15);
  },
  remove: function(effect) {
    this.effects = this.effects.reject(function(e) { return e==effect });
    if(this.effects.length == 0) {
      clearInterval(this.interval);
      this.interval = null;
    }
  },
  loop: function() {
    var timePos = new Date().getTime();
    for(var i=0, len=this.effects.length;i<len;i++) 
      this.effects[i] && this.effects[i].loop(timePos);
  }
});

Effect.Queues = {
  instances: $H(),
  get: function(queueName) {
    if(typeof queueName != 'string') return queueName;
    
    if(!this.instances[queueName])
      this.instances[queueName] = new Effect.ScopedQueue();
      
    return this.instances[queueName];
  }
}
Effect.Queue = Effect.Queues.get('global');

Effect.DefaultOptions = {
  transition: Effect.Transitions.sinoidal,
  duration:   1.0,   // seconds
  fps:        100,   // 100= assume 66fps max.
  sync:       false, // true for combining
  from:       0.0,
  to:         1.0,
  delay:      0.0,
  queue:      'parallel'
}

Effect.Base = function() {};
Effect.Base.prototype = {
  position: null,
  start: function(options) {
    function codeForEvent(options,eventName){
      return (
        (options[eventName+'Internal'] ? 'this.options.'+eventName+'Internal(this);' : '') +
        (options[eventName] ? 'this.options.'+eventName+'(this);' : '')
      );
    }
    if(options.transition === false) options.transition = Effect.Transitions.linear;
    this.options      = Object.extend(Object.extend({},Effect.DefaultOptions), options || {});
    this.currentFrame = 0;
    this.state        = 'idle';
    this.startOn      = this.options.delay*1000;
    this.finishOn     = this.startOn+(this.options.duration*1000);
    this.fromToDelta  = this.options.to-this.options.from;
    this.totalTime    = this.finishOn-this.startOn;
    this.totalFrames  = this.options.fps*this.options.duration;
    
    eval('this.render = function(pos){ '+
      'if(this.state=="idle"){this.state="running";'+
      codeForEvent(options,'beforeSetup')+
      (this.setup ? 'this.setup();':'')+ 
      codeForEvent(options,'afterSetup')+
      '};if(this.state=="running"){'+
      'pos=this.options.transition(pos)*'+this.fromToDelta+'+'+this.options.from+';'+
      'this.position=pos;'+
      codeForEvent(options,'beforeUpdate')+
      (this.update ? 'this.update(pos);':'')+
      codeForEvent(options,'afterUpdate')+
      '}}');
    
    this.event('beforeStart');
    if(!this.options.sync)
      Effect.Queues.get(typeof this.options.queue == 'string' ? 
        'global' : this.options.queue.scope).add(this);
  },
  loop: function(timePos) {
    if(timePos >= this.startOn) {
      if(timePos >= this.finishOn) {
        this.render(1.0);
        this.cancel();
        this.event('beforeFinish');
        if(this.finish) this.finish(); 
        this.event('afterFinish');
        return;  
      }
      var pos   = (timePos - this.startOn) / this.totalTime,
          frame = Math.round(pos * this.totalFrames);
      if(frame > this.currentFrame) {
        this.render(pos);
        this.currentFrame = frame;
      }
    }
  },
  cancel: function() {
    if(!this.options.sync)
      Effect.Queues.get(typeof this.options.queue == 'string' ? 
        'global' : this.options.queue.scope).remove(this);
    this.state = 'finished';
  },
  event: function(eventName) {
    if(this.options[eventName + 'Internal']) this.options[eventName + 'Internal'](this);
    if(this.options[eventName]) this.options[eventName](this);
  },
  inspect: function() {
    var data = $H();
    for(property in this)
      if(typeof this[property] != 'function') data[property] = this[property];
    return '#<Effect:' + data.inspect() + ',options:' + $H(this.options).inspect() + '>';
  }
}

Effect.Parallel = Class.create();
Object.extend(Object.extend(Effect.Parallel.prototype, Effect.Base.prototype), {
  initialize: function(effects) {
    this.effects = effects || [];
    this.start(arguments[1]);
  },
  update: function(position) {
    this.effects.invoke('render', position);
  },
  finish: function(position) {
    this.effects.each( function(effect) {
      effect.render(1.0);
      effect.cancel();
      effect.event('beforeFinish');
      if(effect.finish) effect.finish(position);
      effect.event('afterFinish');
    });
  }
});

Effect.Event = Class.create();
Object.extend(Object.extend(Effect.Event.prototype, Effect.Base.prototype), {
  initialize: function() {
    var options = Object.extend({
      duration: 0
    }, arguments[0] || {});
    this.start(options);
  },
  update: Prototype.emptyFunction
});

Effect.Opacity = Class.create();
Object.extend(Object.extend(Effect.Opacity.prototype, Effect.Base.prototype), {
  initialize: function(element) {
    this.element = $(element);
    if(!this.element) throw(Effect._elementDoesNotExistError);
    // make this work on IE on elements without 'layout'
    if(Prototype.Browser.IE && (!this.element.currentStyle.hasLayout))
      this.element.setStyle({zoom: 1});
    var options = Object.extend({
      from: this.element.getOpacity() || 0.0,
      to:   1.0
    }, arguments[1] || {});
    this.start(options);
  },
  update: function(position) {
    this.element.setOpacity(position);
  }
});

Effect.Move = Class.create();
Object.extend(Object.extend(Effect.Move.prototype, Effect.Base.prototype), {
  initialize: function(element) {
    this.element = $(element);
    if(!this.element) throw(Effect._elementDoesNotExistError);
    var options = Object.extend({
      x:    0,
      y:    0,
      mode: 'relative'
    }, arguments[1] || {});
    this.start(options);
  },
  setup: function() {
    // Bug in Opera: Opera returns the "real" position of a static element or
    // relative element that does not have top/left explicitly set.
    // ==> Always set top and left for position relative elements in your stylesheets 
    // (to 0 if you do not need them) 
    this.element.makePositioned();
    this.originalLeft = parseFloat(this.element.getStyle('left') || '0');
    this.originalTop  = parseFloat(this.element.getStyle('top')  || '0');
    if(this.options.mode == 'absolute') {
      // absolute movement, so we need to calc deltaX and deltaY
      this.options.x = this.options.x - this.originalLeft;
      this.options.y = this.options.y - this.originalTop;
    }
  },
  update: function(position) {
    this.element.setStyle({
      left: Math.round(this.options.x  * position + this.originalLeft) + 'px',
      top:  Math.round(this.options.y  * position + this.originalTop)  + 'px'
    });
  }
});

// for backwards compatibility
Effect.MoveBy = function(element, toTop, toLeft) {
  return new Effect.Move(element, 
    Object.extend({ x: toLeft, y: toTop }, arguments[3] || {}));
};

Effect.Scale = Class.create();
Object.extend(Object.extend(Effect.Scale.prototype, Effect.Base.prototype), {
  initialize: function(element, percent) {
    this.element = $(element);
    if(!this.element) throw(Effect._elementDoesNotExistError);
    var options = Object.extend({
      scaleX: true,
      scaleY: true,
      scaleContent: true,
      scaleFromCenter: false,
      scaleMode: 'box',        // 'box' or 'contents' or {} with provided values
      scaleFrom: 100.0,
      scaleTo:   percent
    }, arguments[2] || {});
    this.start(options);
  },
  setup: function() {
    this.restoreAfterFinish = this.options.restoreAfterFinish || false;
    this.elementPositioning = this.element.getStyle('position');
    
    this.originalStyle = {};
    ['top','left','width','height','fontSize'].each( function(k) {
      this.originalStyle[k] = this.element.style[k];
    }.bind(this));
      
    this.originalTop  = this.element.offsetTop;
    this.originalLeft = this.element.offsetLeft;
    
    var fontSize = this.element.getStyle('font-size') || '100%';
    ['em','px','%','pt'].each( function(fontSizeType) {
      if(fontSize.indexOf(fontSizeType)>0) {
        this.fontSize     = parseFloat(fontSize);
        this.fontSizeType = fontSizeType;
      }
    }.bind(this));
    
    this.factor = (this.options.scaleTo - this.options.scaleFrom)/100;
    
    this.dims = null;
    if(this.options.scaleMode=='box')
      this.dims = [this.element.offsetHeight, this.element.offsetWidth];
    if(/^content/.test(this.options.scaleMode))
      this.dims = [this.element.scrollHeight, this.element.scrollWidth];
    if(!this.dims)
      this.dims = [this.options.scaleMode.originalHeight,
                   this.options.scaleMode.originalWidth];
  },
  update: function(position) {
    var currentScale = (this.options.scaleFrom/100.0) + (this.factor * position);
    if(this.options.scaleContent && this.fontSize)
      this.element.setStyle({fontSize: this.fontSize * currentScale + this.fontSizeType });
    this.setDimensions(this.dims[0] * currentScale, this.dims[1] * currentScale);
  },
  finish: function(position) {
    if(this.restoreAfterFinish) this.element.setStyle(this.originalStyle);
  },
  setDimensions: function(height, width) {
    var d = {};
    if(this.options.scaleX) d.width = Math.round(width) + 'px';
    if(this.options.scaleY) d.height = Math.round(height) + 'px';
    if(this.options.scaleFromCenter) {
      var topd  = (height - this.dims[0])/2;
      var leftd = (width  - this.dims[1])/2;
      if(this.elementPositioning == 'absolute') {
        if(this.options.scaleY) d.top = this.originalTop-topd + 'px';
        if(this.options.scaleX) d.left = this.originalLeft-leftd + 'px';
      } else {
        if(this.options.scaleY) d.top = -topd + 'px';
        if(this.options.scaleX) d.left = -leftd + 'px';
      }
    }
    this.element.setStyle(d);
  }
});

Effect.Highlight = Class.create();
Object.extend(Object.extend(Effect.Highlight.prototype, Effect.Base.prototype), {
  initialize: function(element) {
    this.element = $(element);
    if(!this.element) throw(Effect._elementDoesNotExistError);
    var options = Object.extend({ startcolor: '#ffff99' }, arguments[1] || {});
    this.start(options);
  },
  setup: function() {
    // Prevent executing on elements not in the layout flow
    if(this.element.getStyle('display')=='none') { this.cancel(); return; }
    // Disable background image during the effect
    this.oldStyle = {};
    if (!this.options.keepBackgroundImage) {
      this.oldStyle.backgroundImage = this.element.getStyle('background-image');
      this.element.setStyle({backgroundImage: 'none'});
    }
    if(!this.options.endcolor)
      this.options.endcolor = this.element.getStyle('background-color').parseColor('#ffffff');
    if(!this.options.restorecolor)
      this.options.restorecolor = this.element.getStyle('background-color');
    // init color calculations
    this._base  = $R(0,2).map(function(i){ return parseInt(this.options.startcolor.slice(i*2+1,i*2+3),16) }.bind(this));
    this._delta = $R(0,2).map(function(i){ return parseInt(this.options.endcolor.slice(i*2+1,i*2+3),16)-this._base[i] }.bind(this));
  },
  update: function(position) {
    this.element.setStyle({backgroundColor: $R(0,2).inject('#',function(m,v,i){
      return m+(Math.round(this._base[i]+(this._delta[i]*position)).toColorPart()); }.bind(this)) });
  },
  finish: function() {
    this.element.setStyle(Object.extend(this.oldStyle, {
      backgroundColor: this.options.restorecolor
    }));
  }
});

Effect.ScrollTo = Class.create();
Object.extend(Object.extend(Effect.ScrollTo.prototype, Effect.Base.prototype), {
  initialize: function(element) {
    this.element = $(element);
    this.start(arguments[1] || {});
  },
  setup: function() {
    Position.prepare();
    var offsets = Position.cumulativeOffset(this.element);
    if(this.options.offset) offsets[1] += this.options.offset;
    var max = window.innerHeight ? 
      window.height - window.innerHeight :
      document.body.scrollHeight - 
        (document.documentElement.clientHeight ? 
          document.documentElement.clientHeight : document.body.clientHeight);
    this.scrollStart = Position.deltaY;
    this.delta = (offsets[1] > max ? max : offsets[1]) - this.scrollStart;
  },
  update: function(position) {
    Position.prepare();
    window.scrollTo(Position.deltaX, 
      this.scrollStart + (position*this.delta));
  }
});

/* ------------- combination effects ------------- */

Effect.Fade = function(element) {
  element = $(element);
  var oldOpacity = element.getInlineOpacity();
  var options = Object.extend({
  from: element.getOpacity() || 1.0,
  to:   0.0,
  afterFinishInternal: function(effect) { 
    if(effect.options.to!=0) return;
    effect.element.hide().setStyle({opacity: oldOpacity}); 
  }}, arguments[1] || {});
  return new Effect.Opacity(element,options);
}

Effect.Appear = function(element) {
  element = $(element);
  var options = Object.extend({
  from: (element.getStyle('display') == 'none' ? 0.0 : element.getOpacity() || 0.0),
  to:   1.0,
  // force Safari to render floated elements properly
  afterFinishInternal: function(effect) {
    effect.element.forceRerendering();
  },
  beforeSetup: function(effect) {
    effect.element.setOpacity(effect.options.from).show(); 
  }}, arguments[1] || {});
  return new Effect.Opacity(element,options);
}

Effect.Puff = function(element) {
  element = $(element);
  var oldStyle = { 
    opacity: element.getInlineOpacity(), 
    position: element.getStyle('position'),
    top:  element.style.top,
    left: element.style.left,
    width: element.style.width,
    height: element.style.height
  };
  return new Effect.Parallel(
   [ new Effect.Scale(element, 200, 
      { sync: true, scaleFromCenter: true, scaleContent: true, restoreAfterFinish: true }), 
     new Effect.Opacity(element, { sync: true, to: 0.0 } ) ], 
     Object.extend({ duration: 1.0, 
      beforeSetupInternal: function(effect) {
        Position.absolutize(effect.effects[0].element)
      },
      afterFinishInternal: function(effect) {
         effect.effects[0].element.hide().setStyle(oldStyle); }
     }, arguments[1] || {})
   );
}

Effect.BlindUp = function(element) {
  element = $(element);
  element.makeClipping();
  return new Effect.Scale(element, 0,
    Object.extend({ scaleContent: false, 
      scaleX: false, 
      restoreAfterFinish: true,
      afterFinishInternal: function(effect) {
        effect.element.hide().undoClipping();
      } 
    }, arguments[1] || {})
  );
}

Effect.BlindDown = function(element) {
  element = $(element);
  var elementDimensions = element.getDimensions();
  return new Effect.Scale(element, 100, Object.extend({ 
    scaleContent: false, 
    scaleX: false,
    scaleFrom: 0,
    scaleMode: {originalHeight: elementDimensions.height, originalWidth: elementDimensions.width},
    restoreAfterFinish: true,
    afterSetup: function(effect) {
      effect.element.makeClipping().setStyle({height: '0px'}).show(); 
    },  
    afterFinishInternal: function(effect) {
      effect.element.undoClipping();
    }
  }, arguments[1] || {}));
}

Effect.SwitchOff = function(element) {
  element = $(element);
  var oldOpacity = element.getInlineOpacity();
  return new Effect.Appear(element, Object.extend({
    duration: 0.4,
    from: 0,
    transition: Effect.Transitions.flicker,
    afterFinishInternal: function(effect) {
      new Effect.Scale(effect.element, 1, { 
        duration: 0.3, scaleFromCenter: true,
        scaleX: false, scaleContent: false, restoreAfterFinish: true,
        beforeSetup: function(effect) { 
          effect.element.makePositioned().makeClipping();
        },
        afterFinishInternal: function(effect) {
          effect.element.hide().undoClipping().undoPositioned().setStyle({opacity: oldOpacity});
        }
      })
    }
  }, arguments[1] || {}));
}

Effect.DropOut = function(element) {
  element = $(element);
  var oldStyle = {
    top: element.getStyle('top'),
    left: element.getStyle('left'),
    opacity: element.getInlineOpacity() };
  return new Effect.Parallel(
    [ new Effect.Move(element, {x: 0, y: 100, sync: true }), 
      new Effect.Opacity(element, { sync: true, to: 0.0 }) ],
    Object.extend(
      { duration: 0.5,
        beforeSetup: function(effect) {
          effect.effects[0].element.makePositioned(); 
        },
        afterFinishInternal: function(effect) {
          effect.effects[0].element.hide().undoPositioned().setStyle(oldStyle);
        } 
      }, arguments[1] || {}));
}

Effect.Shake = function(element) {
  element = $(element);
  var oldStyle = {
    top: element.getStyle('top'),
    left: element.getStyle('left') };
    return new Effect.Move(element, 
      { x:  20, y: 0, duration: 0.05, afterFinishInternal: function(effect) {
    new Effect.Move(effect.element,
      { x: -40, y: 0, duration: 0.1,  afterFinishInternal: function(effect) {
    new Effect.Move(effect.element,
      { x:  40, y: 0, duration: 0.1,  afterFinishInternal: function(effect) {
    new Effect.Move(effect.element,
      { x: -40, y: 0, duration: 0.1,  afterFinishInternal: function(effect) {
    new Effect.Move(effect.element,
      { x:  40, y: 0, duration: 0.1,  afterFinishInternal: function(effect) {
    new Effect.Move(effect.element,
      { x: -20, y: 0, duration: 0.05, afterFinishInternal: function(effect) {
        effect.element.undoPositioned().setStyle(oldStyle);
  }}) }}) }}) }}) }}) }});
}

Effect.SlideDown = function(element) {
  element = $(element).cleanWhitespace();
  // SlideDown need to have the content of the element wrapped in a container element with fixed height!
  var oldInnerBottom = element.down().getStyle('bottom');
  var elementDimensions = element.getDimensions();
  return new Effect.Scale(element, 100, Object.extend({ 
    scaleContent: false, 
    scaleX: false, 
    scaleFrom: window.opera ? 0 : 1,
    scaleMode: {originalHeight: elementDimensions.height, originalWidth: elementDimensions.width},
    restoreAfterFinish: true,
    afterSetup: function(effect) {
      effect.element.makePositioned();
      effect.element.down().makePositioned();
      if(window.opera) effect.element.setStyle({top: ''});
      effect.element.makeClipping().setStyle({height: '0px'}).show(); 
    },
    afterUpdateInternal: function(effect) {
      effect.element.down().setStyle({bottom:
        (effect.dims[0] - effect.element.clientHeight) + 'px' }); 
    },
    afterFinishInternal: function(effect) {
      effect.element.undoClipping().undoPositioned();
      effect.element.down().undoPositioned().setStyle({bottom: oldInnerBottom}); }
    }, arguments[1] || {})
  );
}

Effect.SlideUp = function(element) {
  element = $(element).cleanWhitespace();
  var oldInnerBottom = element.down().getStyle('bottom');
  return new Effect.Scale(element, window.opera ? 0 : 1,
   Object.extend({ scaleContent: false, 
    scaleX: false, 
    scaleMode: 'box',
    scaleFrom: 100,
    restoreAfterFinish: true,
    beforeStartInternal: function(effect) {
      effect.element.makePositioned();
      effect.element.down().makePositioned();
      if(window.opera) effect.element.setStyle({top: ''});
      effect.element.makeClipping().show();
    },  
    afterUpdateInternal: function(effect) {
      effect.element.down().setStyle({bottom:
        (effect.dims[0] - effect.element.clientHeight) + 'px' });
    },
    afterFinishInternal: function(effect) {
      effect.element.hide().undoClipping().undoPositioned().setStyle({bottom: oldInnerBottom});
      effect.element.down().undoPositioned();
    }
   }, arguments[1] || {})
  );
}

// Bug in opera makes the TD containing this element expand for a instance after finish 
Effect.Squish = function(element) {
  return new Effect.Scale(element, window.opera ? 1 : 0, { 
    restoreAfterFinish: true,
    beforeSetup: function(effect) {
      effect.element.makeClipping(); 
    },  
    afterFinishInternal: function(effect) {
      effect.element.hide().undoClipping(); 
    }
  });
}

Effect.Grow = function(element) {
  element = $(element);
  var options = Object.extend({
    direction: 'center',
    moveTransition: Effect.Transitions.sinoidal,
    scaleTransition: Effect.Transitions.sinoidal,
    opacityTransition: Effect.Transitions.full
  }, arguments[1] || {});
  var oldStyle = {
    top: element.style.top,
    left: element.style.left,
    height: element.style.height,
    width: element.style.width,
    opacity: element.getInlineOpacity() };

  var dims = element.getDimensions();    
  var initialMoveX, initialMoveY;
  var moveX, moveY;
  
  switch (options.direction) {
    case 'top-left':
      initialMoveX = initialMoveY = moveX = moveY = 0; 
      break;
    case 'top-right':
      initialMoveX = dims.width;
      initialMoveY = moveY = 0;
      moveX = -dims.width;
      break;
    case 'bottom-left':
      initialMoveX = moveX = 0;
      initialMoveY = dims.height;
      moveY = -dims.height;
      break;
    case 'bottom-right':
      initialMoveX = dims.width;
      initialMoveY = dims.height;
      moveX = -dims.width;
      moveY = -dims.height;
      break;
    case 'center':
      initialMoveX = dims.width / 2;
      initialMoveY = dims.height / 2;
      moveX = -dims.width / 2;
      moveY = -dims.height / 2;
      break;
  }
  
  return new Effect.Move(element, {
    x: initialMoveX,
    y: initialMoveY,
    duration: 0.01, 
    beforeSetup: function(effect) {
      effect.element.hide().makeClipping().makePositioned();
    },
    afterFinishInternal: function(effect) {
      new Effect.Parallel(
        [ new Effect.Opacity(effect.element, { sync: true, to: 1.0, from: 0.0, transition: options.opacityTransition }),
          new Effect.Move(effect.element, { x: moveX, y: moveY, sync: true, transition: options.moveTransition }),
          new Effect.Scale(effect.element, 100, {
            scaleMode: { originalHeight: dims.height, originalWidth: dims.width }, 
            sync: true, scaleFrom: window.opera ? 1 : 0, transition: options.scaleTransition, restoreAfterFinish: true})
        ], Object.extend({
             beforeSetup: function(effect) {
               effect.effects[0].element.setStyle({height: '0px'}).show(); 
             },
             afterFinishInternal: function(effect) {
               effect.effects[0].element.undoClipping().undoPositioned().setStyle(oldStyle); 
             }
           }, options)
      )
    }
  });
}

Effect.Shrink = function(element) {
  element = $(element);
  var options = Object.extend({
    direction: 'center',
    moveTransition: Effect.Transitions.sinoidal,
    scaleTransition: Effect.Transitions.sinoidal,
    opacityTransition: Effect.Transitions.none
  }, arguments[1] || {});
  var oldStyle = {
    top: element.style.top,
    left: element.style.left,
    height: element.style.height,
    width: element.style.width,
    opacity: element.getInlineOpacity() };

  var dims = element.getDimensions();
  var moveX, moveY;
  
  switch (options.direction) {
    case 'top-left':
      moveX = moveY = 0;
      break;
    case 'top-right':
      moveX = dims.width;
      moveY = 0;
      break;
    case 'bottom-left':
      moveX = 0;
      moveY = dims.height;
      break;
    case 'bottom-right':
      moveX = dims.width;
      moveY = dims.height;
      break;
    case 'center':  
      moveX = dims.width / 2;
      moveY = dims.height / 2;
      break;
  }
  
  return new Effect.Parallel(
    [ new Effect.Opacity(element, { sync: true, to: 0.0, from: 1.0, transition: options.opacityTransition }),
      new Effect.Scale(element, window.opera ? 1 : 0, { sync: true, transition: options.scaleTransition, restoreAfterFinish: true}),
      new Effect.Move(element, { x: moveX, y: moveY, sync: true, transition: options.moveTransition })
    ], Object.extend({            
         beforeStartInternal: function(effect) {
           effect.effects[0].element.makePositioned().makeClipping(); 
         },
         afterFinishInternal: function(effect) {
           effect.effects[0].element.hide().undoClipping().undoPositioned().setStyle(oldStyle); }
       }, options)
  );
}

Effect.Pulsate = function(element) {
  element = $(element);
  var options    = arguments[1] || {};
  var oldOpacity = element.getInlineOpacity();
  var transition = options.transition || Effect.Transitions.sinoidal;
  var reverser   = function(pos){ return transition(1-Effect.Transitions.pulse(pos, options.pulses)) };
  reverser.bind(transition);
  return new Effect.Opacity(element, 
    Object.extend(Object.extend({  duration: 2.0, from: 0,
      afterFinishInternal: function(effect) { effect.element.setStyle({opacity: oldOpacity}); }
    }, options), {transition: reverser}));
}

Effect.Fold = function(element) {
  element = $(element);
  var oldStyle = {
    top: element.style.top,
    left: element.style.left,
    width: element.style.width,
    height: element.style.height };
  element.makeClipping();
  return new Effect.Scale(element, 5, Object.extend({   
    scaleContent: false,
    scaleX: false,
    afterFinishInternal: function(effect) {
    new Effect.Scale(element, 1, { 
      scaleContent: false, 
      scaleY: false,
      afterFinishInternal: function(effect) {
        effect.element.hide().undoClipping().setStyle(oldStyle);
      } });
  }}, arguments[1] || {}));
};

Effect.Morph = Class.create();
Object.extend(Object.extend(Effect.Morph.prototype, Effect.Base.prototype), {
  initialize: function(element) {
    this.element = $(element);
    if(!this.element) throw(Effect._elementDoesNotExistError);
    var options = Object.extend({
      style: {}
    }, arguments[1] || {});
    if (typeof options.style == 'string') {
      if(options.style.indexOf(':') == -1) {
        var cssText = '', selector = '.' + options.style;
        $A(document.styleSheets).reverse().each(function(styleSheet) {
          if (styleSheet.cssRules) cssRules = styleSheet.cssRules;
          else if (styleSheet.rules) cssRules = styleSheet.rules;
          $A(cssRules).reverse().each(function(rule) {
            if (selector == rule.selectorText) {
              cssText = rule.style.cssText;
              throw $break;
            }
          });
          if (cssText) throw $break;
        });
        this.style = cssText.parseStyle();
        options.afterFinishInternal = function(effect){
          effect.element.addClassName(effect.options.style);
          effect.transforms.each(function(transform) {
            if(transform.style != 'opacity')
              effect.element.style[transform.style] = '';
          });
        }
      } else this.style = options.style.parseStyle();
    } else this.style = $H(options.style)
    this.start(options);
  },
  setup: function(){
    function parseColor(color){
      if(!color || ['rgba(0, 0, 0, 0)','transparent'].include(color)) color = '#ffffff';
      color = color.parseColor();
      return $R(0,2).map(function(i){
        return parseInt( color.slice(i*2+1,i*2+3), 16 ) 
      });
    }
    this.transforms = this.style.map(function(pair){
      var property = pair[0], value = pair[1], unit = null;

      if(value.parseColor('#zzzzzz') != '#zzzzzz') {
        value = value.parseColor();
        unit  = 'color';
      } else if(property == 'opacity') {
        value = parseFloat(value);
        if(Prototype.Browser.IE && (!this.element.currentStyle.hasLayout))
          this.element.setStyle({zoom: 1});
      } else if(Element.CSS_LENGTH.test(value)) {
          var components = value.match(/^([\+\-]?[0-9\.]+)(.*)$/);
          value = parseFloat(components[1]);
          unit = (components.length == 3) ? components[2] : null;
      }

      var originalValue = this.element.getStyle(property);
      return { 
        style: property.camelize(), 
        originalValue: unit=='color' ? parseColor(originalValue) : parseFloat(originalValue || 0), 
        targetValue: unit=='color' ? parseColor(value) : value,
        unit: unit
      };
    }.bind(this)).reject(function(transform){
      return (
        (transform.originalValue == transform.targetValue) ||
        (
          transform.unit != 'color' &&
          (isNaN(transform.originalValue) || isNaN(transform.targetValue))
        )
      )
    });
  },
  update: function(position) {
    var style = {}, transform, i = this.transforms.length;
    while(i--)
      style[(transform = this.transforms[i]).style] = 
        transform.unit=='color' ? '#'+
          (Math.round(transform.originalValue[0]+
            (transform.targetValue[0]-transform.originalValue[0])*position)).toColorPart() +
          (Math.round(transform.originalValue[1]+
            (transform.targetValue[1]-transform.originalValue[1])*position)).toColorPart() +
          (Math.round(transform.originalValue[2]+
            (transform.targetValue[2]-transform.originalValue[2])*position)).toColorPart() :
        transform.originalValue + Math.round(
          ((transform.targetValue - transform.originalValue) * position) * 1000)/1000 + transform.unit;
    this.element.setStyle(style, true);
  }
});

Effect.Transform = Class.create();
Object.extend(Effect.Transform.prototype, {
  initialize: function(tracks){
    this.tracks  = [];
    this.options = arguments[1] || {};
    this.addTracks(tracks);
  },
  addTracks: function(tracks){
    tracks.each(function(track){
      var data = $H(track).values().first();
      this.tracks.push($H({
        ids:     $H(track).keys().first(),
        effect:  Effect.Morph,
        options: { style: data }
      }));
    }.bind(this));
    return this;
  },
  play: function(){
    return new Effect.Parallel(
      this.tracks.map(function(track){
        var elements = [$(track.ids) || $$(track.ids)].flatten();
        return elements.map(function(e){ return new track.effect(e, Object.extend({ sync:true }, track.options)) });
      }).flatten(),
      this.options
    );
  }
});

Element.CSS_PROPERTIES = $w(
  'backgroundColor backgroundPosition borderBottomColor borderBottomStyle ' + 
  'borderBottomWidth borderLeftColor borderLeftStyle borderLeftWidth ' +
  'borderRightColor borderRightStyle borderRightWidth borderSpacing ' +
  'borderTopColor borderTopStyle borderTopWidth bottom clip color ' +
  'fontSize fontWeight height left letterSpacing lineHeight ' +
  'marginBottom marginLeft marginRight marginTop markerOffset maxHeight '+
  'maxWidth minHeight minWidth opacity outlineColor outlineOffset ' +
  'outlineWidth paddingBottom paddingLeft paddingRight paddingTop ' +
  'right textIndent top width wordSpacing zIndex');
  
Element.CSS_LENGTH = /^(([\+\-]?[0-9\.]+)(em|ex|px|in|cm|mm|pt|pc|\%))|0$/;

String.prototype.parseStyle = function(){
  var element = document.createElement('div');
  element.innerHTML = '<div style="' + this + '"></div>';
  var style = element.childNodes[0].style, styleRules = $H();
  
  Element.CSS_PROPERTIES.each(function(property){
    if(style[property]) styleRules[property] = style[property]; 
  });
  if(Prototype.Browser.IE && this.indexOf('opacity') > -1) {
    styleRules.opacity = this.match(/opacity:\s*((?:0|1)?(?:\.\d*)?)/)[1];
  }
  return styleRules;
};

Element.morph = function(element, style) {
  new Effect.Morph(element, Object.extend({ style: style }, arguments[2] || {}));
  return element;
};

['getInlineOpacity','forceRerendering','setContentZoom',
 'collectTextNodes','collectTextNodesIgnoreClass','morph'].each( 
  function(f) { Element.Methods[f] = Element[f]; }
);

Element.Methods.visualEffect = function(element, effect, options) {
  s = effect.dasherize().camelize();
  effect_class = s.charAt(0).toUpperCase() + s.substring(1);
  new Effect[effect_class](element, options);
  return $(element);
};

Element.addMethods();

// Copyright (c) 2005-2007 Thomas Fuchs (http://script.aculo.us, http://mir.aculo.us)
//           (c) 2005-2007 Sammi Williams (http://www.oriontransfer.co.nz, sammi@oriontransfer.co.nz)
// 
// script.aculo.us is freely distributable under the terms of an MIT-style license.
// For details, see the script.aculo.us web site: http://script.aculo.us/

if(typeof Effect == 'undefined')
  throw("dragdrop.js requires including script.aculo.us' effects.js library");

var Droppables = {
  drops: [],

  remove: function(element) {
    this.drops = this.drops.reject(function(d) { return d.element==$(element) });
  },

  add: function(element) {
    element = $(element);
    var options = Object.extend({
      greedy:     true,
      hoverclass: null,
      tree:       false
    }, arguments[1] || {});

    // cache containers
    if(options.containment) {
      options._containers = [];
      var containment = options.containment;
      if((typeof containment == 'object') && 
        (containment.constructor == Array)) {
        containment.each( function(c) { options._containers.push($(c)) });
      } else {
        options._containers.push($(containment));
      }
    }
    
    if(options.accept) options.accept = [options.accept].flatten();

    Element.makePositioned(element); // fix IE
    options.element = element;

    this.drops.push(options);
  },
  
  findDeepestChild: function(drops) {
    deepest = drops[0];
      
    for (i = 1; i < drops.length; ++i)
      if (Element.isParent(drops[i].element, deepest.element))
        deepest = drops[i];
    
    return deepest;
  },

  isContained: function(element, drop) {
    var containmentNode;
    if(drop.tree) {
      containmentNode = element.treeNode; 
    } else {
      containmentNode = element.parentNode;
    }
    return drop._containers.detect(function(c) { return containmentNode == c });
  },
  
  isAffected: function(point, element, drop) {
    return (
      (drop.element!=element) &&
      ((!drop._containers) ||
        this.isContained(element, drop)) &&
      ((!drop.accept) ||
        (Element.classNames(element).detect( 
          function(v) { return drop.accept.include(v) } ) )) &&
      Position.within(drop.element, point[0], point[1]) );
  },

  deactivate: function(drop) {
    if(drop.hoverclass)
      Element.removeClassName(drop.element, drop.hoverclass);
    this.last_active = null;
  },

  activate: function(drop) {
    if(drop.hoverclass)
      Element.addClassName(drop.element, drop.hoverclass);
    this.last_active = drop;
  },

  show: function(point, element) {
    if(!this.drops.length) return;
    var affected = [];
    
    if(this.last_active) this.deactivate(this.last_active);
    this.drops.each( function(drop) {
      if(Droppables.isAffected(point, element, drop))
        affected.push(drop);
    });
        
    if(affected.length>0) {
      drop = Droppables.findDeepestChild(affected);
      Position.within(drop.element, point[0], point[1]);
      if(drop.onHover)
        drop.onHover(element, drop.element, Position.overlap(drop.overlap, drop.element));
      
      Droppables.activate(drop);
    }
  },

  fire: function(event, element) {
    if(!this.last_active) return;
    Position.prepare();

    if (this.isAffected([Event.pointerX(event), Event.pointerY(event)], element, this.last_active))
      if (this.last_active.onDrop) {
        this.last_active.onDrop(element, this.last_active.element, event); 
        return true; 
      }
  },

  reset: function() {
    if(this.last_active)
      this.deactivate(this.last_active);
  }
}

var Draggables = {
  drags: [],
  observers: [],
  
  register: function(draggable) {
    if(this.drags.length == 0) {
      this.eventMouseUp   = this.endDrag.bindAsEventListener(this);
      this.eventMouseMove = this.updateDrag.bindAsEventListener(this);
      this.eventKeypress  = this.keyPress.bindAsEventListener(this);
      
      Event.observe(document, "mouseup", this.eventMouseUp);
      Event.observe(document, "mousemove", this.eventMouseMove);
      Event.observe(document, "keypress", this.eventKeypress);
    }
    this.drags.push(draggable);
  },
  
  unregister: function(draggable) {
    this.drags = this.drags.reject(function(d) { return d==draggable });
    if(this.drags.length == 0) {
      Event.stopObserving(document, "mouseup", this.eventMouseUp);
      Event.stopObserving(document, "mousemove", this.eventMouseMove);
      Event.stopObserving(document, "keypress", this.eventKeypress);
    }
  },
  
  activate: function(draggable) {
    if(draggable.options.delay) { 
      this._timeout = setTimeout(function() { 
        Draggables._timeout = null; 
        window.focus(); 
        Draggables.activeDraggable = draggable; 
      }.bind(this), draggable.options.delay); 
    } else {
      window.focus(); // allows keypress events if window isn't currently focused, fails for Safari
      this.activeDraggable = draggable;
    }
  },
  
  deactivate: function() {
    this.activeDraggable = null;
  },
  
  updateDrag: function(event) {
    if(!this.activeDraggable) return;
    var pointer = [Event.pointerX(event), Event.pointerY(event)];
    // Mozilla-based browsers fire successive mousemove events with
    // the same coordinates, prevent needless redrawing (moz bug?)
    if(this._lastPointer && (this._lastPointer.inspect() == pointer.inspect())) return;
    this._lastPointer = pointer;
    
    this.activeDraggable.updateDrag(event, pointer);
  },
  
  endDrag: function(event) {
    if(this._timeout) { 
      clearTimeout(this._timeout); 
      this._timeout = null; 
    }
    if(!this.activeDraggable) return;
    this._lastPointer = null;
    this.activeDraggable.endDrag(event);
    this.activeDraggable = null;
  },
  
  keyPress: function(event) {
    if(this.activeDraggable)
      this.activeDraggable.keyPress(event);
  },
  
  addObserver: function(observer) {
    this.observers.push(observer);
    this._cacheObserverCallbacks();
  },
  
  removeObserver: function(element) {  // element instead of observer fixes mem leaks
    this.observers = this.observers.reject( function(o) { return o.element==element });
    this._cacheObserverCallbacks();
  },
  
  notify: function(eventName, draggable, event) {  // 'onStart', 'onEnd', 'onDrag'
    if(this[eventName+'Count'] > 0)
      this.observers.each( function(o) {
        if(o[eventName]) o[eventName](eventName, draggable, event);
      });
    if(draggable.options[eventName]) draggable.options[eventName](draggable, event);
  },
  
  _cacheObserverCallbacks: function() {
    ['onStart','onEnd','onDrag'].each( function(eventName) {
      Draggables[eventName+'Count'] = Draggables.observers.select(
        function(o) { return o[eventName]; }
      ).length;
    });
  }
}

/*--------------------------------------------------------------------------*/

var Draggable = Class.create();
Draggable._dragging    = {};

Draggable.prototype = {
  initialize: function(element) {
    var defaults = {
      handle: false,
      reverteffect: function(element, top_offset, left_offset) {
        var dur = Math.sqrt(Math.abs(top_offset^2)+Math.abs(left_offset^2))*0.02;
        new Effect.Move(element, { x: -left_offset, y: -top_offset, duration: dur,
          queue: {scope:'_draggable', position:'end'}
        });
      },
      endeffect: function(element) {
        var toOpacity = typeof element._opacity == 'number' ? element._opacity : 1.0;
        new Effect.Opacity(element, {duration:0.2, from:0.7, to:toOpacity, 
          queue: {scope:'_draggable', position:'end'},
          afterFinish: function(){ 
            Draggable._dragging[element] = false 
          }
        }); 
      },
      zindex: 1000,
      revert: false,
      quiet: false,
      scroll: false,
      scrollSensitivity: 20,
      scrollSpeed: 15,
      snap: false,  // false, or xy or [x,y] or function(x,y){ return [x,y] }
      delay: 0
    };
    
    if(!arguments[1] || typeof arguments[1].endeffect == 'undefined')
      Object.extend(defaults, {
        starteffect: function(element) {
          element._opacity = Element.getOpacity(element);
          Draggable._dragging[element] = true;
          new Effect.Opacity(element, {duration:0.2, from:element._opacity, to:0.7}); 
        }
      });
    
    var options = Object.extend(defaults, arguments[1] || {});

    this.element = $(element);
    
    if(options.handle && (typeof options.handle == 'string'))
      this.handle = this.element.down('.'+options.handle, 0);
    
    if(!this.handle) this.handle = $(options.handle);
    if(!this.handle) this.handle = this.element;
    
    if(options.scroll && !options.scroll.scrollTo && !options.scroll.outerHTML) {
      options.scroll = $(options.scroll);
      this._isScrollChild = Element.childOf(this.element, options.scroll);
    }

    Element.makePositioned(this.element); // fix IE    

    this.delta    = this.currentDelta();
    this.options  = options;
    this.dragging = false;   

    this.eventMouseDown = this.initDrag.bindAsEventListener(this);
    Event.observe(this.handle, "mousedown", this.eventMouseDown);
    
    Draggables.register(this);
  },
  
  destroy: function() {
    Event.stopObserving(this.handle, "mousedown", this.eventMouseDown);
    Draggables.unregister(this);
  },
  
  currentDelta: function() {
    return([
      parseInt(Element.getStyle(this.element,'left') || '0'),
      parseInt(Element.getStyle(this.element,'top') || '0')]);
  },
  
  initDrag: function(event) {
    if(typeof Draggable._dragging[this.element] != 'undefined' &&
      Draggable._dragging[this.element]) return;
    if(Event.isLeftClick(event)) {    
      // abort on form elements, fixes a Firefox issue
      var src = Event.element(event);
      if((tag_name = src.tagName.toUpperCase()) && (
        tag_name=='INPUT' ||
        tag_name=='SELECT' ||
        tag_name=='OPTION' ||
        tag_name=='BUTTON' ||
        tag_name=='TEXTAREA')) return;
        
      var pointer = [Event.pointerX(event), Event.pointerY(event)];
      var pos     = Position.cumulativeOffset(this.element);
      this.offset = [0,1].map( function(i) { return (pointer[i] - pos[i]) });
      
      Draggables.activate(this);
      Event.stop(event);
    }
  },
  
  startDrag: function(event) {
    this.dragging = true;
    
    if(this.options.zindex) {
      this.originalZ = parseInt(Element.getStyle(this.element,'z-index') || 0);
      this.element.style.zIndex = this.options.zindex;
    }
    
    if(this.options.ghosting) {
      this._clone = this.element.cloneNode(true);
      Position.absolutize(this.element);
      this.element.parentNode.insertBefore(this._clone, this.element);
    }
    
    if(this.options.scroll) {
      if (this.options.scroll == window) {
        var where = this._getWindowScroll(this.options.scroll);
        this.originalScrollLeft = where.left;
        this.originalScrollTop = where.top;
      } else {
        this.originalScrollLeft = this.options.scroll.scrollLeft;
        this.originalScrollTop = this.options.scroll.scrollTop;
      }
    }
    
    Draggables.notify('onStart', this, event);
        
    if(this.options.starteffect) this.options.starteffect(this.element);
  },
  
  updateDrag: function(event, pointer) {
    if(!this.dragging) this.startDrag(event);
    
    if(!this.options.quiet){
      Position.prepare();
      Droppables.show(pointer, this.element);
    }
    
    Draggables.notify('onDrag', this, event);
    
    this.draw(pointer);
    if(this.options.change) this.options.change(this);
    
    if(this.options.scroll) {
      this.stopScrolling();
      
      var p;
      if (this.options.scroll == window) {
        with(this._getWindowScroll(this.options.scroll)) { p = [ left, top, left+width, top+height ]; }
      } else {
        p = Position.page(this.options.scroll);
        p[0] += this.options.scroll.scrollLeft + Position.deltaX;
        p[1] += this.options.scroll.scrollTop + Position.deltaY;
        p.push(p[0]+this.options.scroll.offsetWidth);
        p.push(p[1]+this.options.scroll.offsetHeight);
      }
      var speed = [0,0];
      if(pointer[0] < (p[0]+this.options.scrollSensitivity)) speed[0] = pointer[0]-(p[0]+this.options.scrollSensitivity);
      if(pointer[1] < (p[1]+this.options.scrollSensitivity)) speed[1] = pointer[1]-(p[1]+this.options.scrollSensitivity);
      if(pointer[0] > (p[2]-this.options.scrollSensitivity)) speed[0] = pointer[0]-(p[2]-this.options.scrollSensitivity);
      if(pointer[1] > (p[3]-this.options.scrollSensitivity)) speed[1] = pointer[1]-(p[3]-this.options.scrollSensitivity);
      this.startScrolling(speed);
    }
    
    // fix AppleWebKit rendering
    if(Prototype.Browser.WebKit) window.scrollBy(0,0);
    
    Event.stop(event);
  },
  
  finishDrag: function(event, success) {
    this.dragging = false;
    
    if(this.options.quiet){
      Position.prepare();
      var pointer = [Event.pointerX(event), Event.pointerY(event)];
      Droppables.show(pointer, this.element);
    }

    if(this.options.ghosting) {
      Position.relativize(this.element);
      Element.remove(this._clone);
      this._clone = null;
    }

    var dropped = false; 
    if(success) { 
      dropped = Droppables.fire(event, this.element); 
      if (!dropped) dropped = false; 
    }
    if(dropped && this.options.onDropped) this.options.onDropped(this.element);
    Draggables.notify('onEnd', this, event);

    var revert = this.options.revert;
    if(revert && typeof revert == 'function') revert = revert(this.element);
    
    var d = this.currentDelta();
    if(revert && this.options.reverteffect) {
      if (dropped == 0 || revert != 'failure')
        this.options.reverteffect(this.element,
          d[1]-this.delta[1], d[0]-this.delta[0]);
    } else {
      this.delta = d;
    }

    if(this.options.zindex)
      this.element.style.zIndex = this.originalZ;

    if(this.options.endeffect) 
      this.options.endeffect(this.element);
      
    Draggables.deactivate(this);
    Droppables.reset();
  },
  
  keyPress: function(event) {
    if(event.keyCode!=Event.KEY_ESC) return;
    this.finishDrag(event, false);
    Event.stop(event);
  },
  
  endDrag: function(event) {
    if(!this.dragging) return;
    this.stopScrolling();
    this.finishDrag(event, true);
    Event.stop(event);
  },
  
  draw: function(point) {
    var pos = Position.cumulativeOffset(this.element);
    if(this.options.ghosting) {
      var r   = Position.realOffset(this.element);
      pos[0] += r[0] - Position.deltaX; pos[1] += r[1] - Position.deltaY;
    }
    
    var d = this.currentDelta();
    pos[0] -= d[0]; pos[1] -= d[1];
    
    if(this.options.scroll && (this.options.scroll != window && this._isScrollChild)) {
      pos[0] -= this.options.scroll.scrollLeft-this.originalScrollLeft;
      pos[1] -= this.options.scroll.scrollTop-this.originalScrollTop;
    }
    
    var p = [0,1].map(function(i){ 
      return (point[i]-pos[i]-this.offset[i]) 
    }.bind(this));
    
    if(this.options.snap) {
      if(typeof this.options.snap == 'function') {
        p = this.options.snap(p[0],p[1],this);
      } else {
      if(this.options.snap instanceof Array) {
        p = p.map( function(v, i) {
          return Math.round(v/this.options.snap[i])*this.options.snap[i] }.bind(this))
      } else {
        p = p.map( function(v) {
          return Math.round(v/this.options.snap)*this.options.snap }.bind(this))
      }
    }}
    
    var style = this.element.style;
    if((!this.options.constraint) || (this.options.constraint=='horizontal'))
      style.left = p[0] + "px";
    if((!this.options.constraint) || (this.options.constraint=='vertical'))
      style.top  = p[1] + "px";
    
    if(style.visibility=="hidden") style.visibility = ""; // fix gecko rendering
  },
  
  stopScrolling: function() {
    if(this.scrollInterval) {
      clearInterval(this.scrollInterval);
      this.scrollInterval = null;
      Draggables._lastScrollPointer = null;
    }
  },
  
  startScrolling: function(speed) {
    if(!(speed[0] || speed[1])) return;
    this.scrollSpeed = [speed[0]*this.options.scrollSpeed,speed[1]*this.options.scrollSpeed];
    this.lastScrolled = new Date();
    this.scrollInterval = setInterval(this.scroll.bind(this), 10);
  },
  
  scroll: function() {
    var current = new Date();
    var delta = current - this.lastScrolled;
    this.lastScrolled = current;
    if(this.options.scroll == window) {
      with (this._getWindowScroll(this.options.scroll)) {
        if (this.scrollSpeed[0] || this.scrollSpeed[1]) {
          var d = delta / 1000;
          this.options.scroll.scrollTo( left + d*this.scrollSpeed[0], top + d*this.scrollSpeed[1] );
        }
      }
    } else {
      this.options.scroll.scrollLeft += this.scrollSpeed[0] * delta / 1000;
      this.options.scroll.scrollTop  += this.scrollSpeed[1] * delta / 1000;
    }
    
    Position.prepare();
    Droppables.show(Draggables._lastPointer, this.element);
    Draggables.notify('onDrag', this);
    if (this._isScrollChild) {
      Draggables._lastScrollPointer = Draggables._lastScrollPointer || $A(Draggables._lastPointer);
      Draggables._lastScrollPointer[0] += this.scrollSpeed[0] * delta / 1000;
      Draggables._lastScrollPointer[1] += this.scrollSpeed[1] * delta / 1000;
      if (Draggables._lastScrollPointer[0] < 0)
        Draggables._lastScrollPointer[0] = 0;
      if (Draggables._lastScrollPointer[1] < 0)
        Draggables._lastScrollPointer[1] = 0;
      this.draw(Draggables._lastScrollPointer);
    }
    
    if(this.options.change) this.options.change(this);
  },
  
  _getWindowScroll: function(w) {
    var T, L, W, H;
    with (w.document) {
      if (w.document.documentElement && documentElement.scrollTop) {
        T = documentElement.scrollTop;
        L = documentElement.scrollLeft;
      } else if (w.document.body) {
        T = body.scrollTop;
        L = body.scrollLeft;
      }
      if (w.innerWidth) {
        W = w.innerWidth;
        H = w.innerHeight;
      } else if (w.document.documentElement && documentElement.clientWidth) {
        W = documentElement.clientWidth;
        H = documentElement.clientHeight;
      } else {
        W = body.offsetWidth;
        H = body.offsetHeight
      }
    }
    return { top: T, left: L, width: W, height: H };
  }
}

/*--------------------------------------------------------------------------*/

var SortableObserver = Class.create();
SortableObserver.prototype = {
  initialize: function(element, observer) {
    this.element   = $(element);
    this.observer  = observer;
    this.lastValue = Sortable.serialize(this.element);
  },
  
  onStart: function() {
    this.lastValue = Sortable.serialize(this.element);
  },
  
  onEnd: function() {
    Sortable.unmark();
    if(this.lastValue != Sortable.serialize(this.element))
      this.observer(this.element)
  }
}

var Sortable = {
  SERIALIZE_RULE: /^[^_\-](?:[A-Za-z0-9\-\_]*)[_](.*)$/,
  
  sortables: {},
  
  _findRootElement: function(element) {
    while (element.tagName.toUpperCase() != "BODY") {  
      if(element.id && Sortable.sortables[element.id]) return element;
      element = element.parentNode;
    }
  },

  options: function(element) {
    element = Sortable._findRootElement($(element));
    if(!element) return;
    return Sortable.sortables[element.id];
  },
  
  destroy: function(element){
    var s = Sortable.options(element);
    
    if(s) {
      Draggables.removeObserver(s.element);
      s.droppables.each(function(d){ Droppables.remove(d) });
      s.draggables.invoke('destroy');
      
      delete Sortable.sortables[s.element.id];
    }
  },

  create: function(element) {
    element = $(element);
    var options = Object.extend({ 
      element:     element,
      tag:         'li',       // assumes li children, override with tag: 'tagname'
      dropOnEmpty: false,
      tree:        false,
      treeTag:     'ul',
      overlap:     'vertical', // one of 'vertical', 'horizontal'
      constraint:  'vertical', // one of 'vertical', 'horizontal', false
      containment: element,    // also takes array of elements (or id's); or false
      handle:      false,      // or a CSS class
      only:        false,
      delay:       0,
      hoverclass:  null,
      ghosting:    false,
      quiet:       false, 
      scroll:      false,
      scrollSensitivity: 20,
      scrollSpeed: 15,
      format:      this.SERIALIZE_RULE,
      
      // these take arrays of elements or ids and can be 
      // used for better initialization performance
      elements:    false,
      handles:     false,
      
      onChange:    Prototype.emptyFunction,
      onUpdate:    Prototype.emptyFunction
    }, arguments[1] || {});

    // clear any old sortable with same element
    this.destroy(element);

    // build options for the draggables
    var options_for_draggable = {
      revert:      true,
      quiet:       options.quiet,
      scroll:      options.scroll,
      scrollSpeed: options.scrollSpeed,
      scrollSensitivity: options.scrollSensitivity,
      delay:       options.delay,
      ghosting:    options.ghosting,
      constraint:  options.constraint,
      handle:      options.handle };

    if(options.starteffect)
      options_for_draggable.starteffect = options.starteffect;

    if(options.reverteffect)
      options_for_draggable.reverteffect = options.reverteffect;
    else
      if(options.ghosting) options_for_draggable.reverteffect = function(element) {
        element.style.top  = 0;
        element.style.left = 0;
      };

    if(options.endeffect)
      options_for_draggable.endeffect = options.endeffect;

    if(options.zindex)
      options_for_draggable.zindex = options.zindex;

    // build options for the droppables  
    var options_for_droppable = {
      overlap:     options.overlap,
      containment: options.containment,
      tree:        options.tree,
      hoverclass:  options.hoverclass,
      onHover:     Sortable.onHover
    }
    
    var options_for_tree = {
      onHover:      Sortable.onEmptyHover,
      overlap:      options.overlap,
      containment:  options.containment,
      hoverclass:   options.hoverclass
    }

    // fix for gecko engine
    Element.cleanWhitespace(element); 

    options.draggables = [];
    options.droppables = [];

    // drop on empty handling
    if(options.dropOnEmpty || options.tree) {
      Droppables.add(element, options_for_tree);
      options.droppables.push(element);
    }

    (options.elements || this.findElements(element, options) || []).each( function(e,i) {
      var handle = options.handles ? $(options.handles[i]) :
        (options.handle ? $(e).getElementsByClassName(options.handle)[0] : e); 
      options.draggables.push(
        new Draggable(e, Object.extend(options_for_draggable, { handle: handle })));
      Droppables.add(e, options_for_droppable);
      if(options.tree) e.treeNode = element;
      options.droppables.push(e);      
    });
    
    if(options.tree) {
      (Sortable.findTreeElements(element, options) || []).each( function(e) {
        Droppables.add(e, options_for_tree);
        e.treeNode = element;
        options.droppables.push(e);
      });
    }

    // keep reference
    this.sortables[element.id] = options;

    // for onupdate
    Draggables.addObserver(new SortableObserver(element, options.onUpdate));

  },

  // return all suitable-for-sortable elements in a guaranteed order
  findElements: function(element, options) {
    return Element.findChildren(
      element, options.only, options.tree ? true : false, options.tag);
  },
  
  findTreeElements: function(element, options) {
    return Element.findChildren(
      element, options.only, options.tree ? true : false, options.treeTag);
  },

  onHover: function(element, dropon, overlap) {
    if(Element.isParent(dropon, element)) return;

    if(overlap > .33 && overlap < .66 && Sortable.options(dropon).tree) {
      return;
    } else if(overlap>0.5) {
      Sortable.mark(dropon, 'before');
      if(dropon.previousSibling != element) {
        var oldParentNode = element.parentNode;
        element.style.visibility = "hidden"; // fix gecko rendering
        dropon.parentNode.insertBefore(element, dropon);
        if(dropon.parentNode!=oldParentNode) 
          Sortable.options(oldParentNode).onChange(element);
        Sortable.options(dropon.parentNode).onChange(element);
      }
    } else {
      Sortable.mark(dropon, 'after');
      var nextElement = dropon.nextSibling || null;
      if(nextElement != element) {
        var oldParentNode = element.parentNode;
        element.style.visibility = "hidden"; // fix gecko rendering
        dropon.parentNode.insertBefore(element, nextElement);
        if(dropon.parentNode!=oldParentNode) 
          Sortable.options(oldParentNode).onChange(element);
        Sortable.options(dropon.parentNode).onChange(element);
      }
    }
  },
  
  onEmptyHover: function(element, dropon, overlap) {
    var oldParentNode = element.parentNode;
    var droponOptions = Sortable.options(dropon);
        
    if(!Element.isParent(dropon, element)) {
      var index;
      
      var children = Sortable.findElements(dropon, {tag: droponOptions.tag, only: droponOptions.only});
      var child = null;
            
      if(children) {
        var offset = Element.offsetSize(dropon, droponOptions.overlap) * (1.0 - overlap);
        
        for (index = 0; index < children.length; index += 1) {
          if (offset - Element.offsetSize (children[index], droponOptions.overlap) >= 0) {
            offset -= Element.offsetSize (children[index], droponOptions.overlap);
          } else if (offset - (Element.offsetSize (children[index], droponOptions.overlap) / 2) >= 0) {
            child = index + 1 < children.length ? children[index + 1] : null;
            break;
          } else {
            child = children[index];
            break;
          }
        }
      }
      
      dropon.insertBefore(element, child);
      
      Sortable.options(oldParentNode).onChange(element);
      droponOptions.onChange(element);
    }
  },

  unmark: function() {
    if(Sortable._marker) Sortable._marker.hide();
  },

  mark: function(dropon, position) {
    // mark on ghosting only
    var sortable = Sortable.options(dropon.parentNode);
    if(sortable && !sortable.ghosting) return; 

    if(!Sortable._marker) {
      Sortable._marker = 
        ($('dropmarker') || Element.extend(document.createElement('DIV'))).
          hide().addClassName('dropmarker').setStyle({position:'absolute'});
      document.getElementsByTagName("body").item(0).appendChild(Sortable._marker);
    }    
    var offsets = Position.cumulativeOffset(dropon);
    Sortable._marker.setStyle({left: offsets[0]+'px', top: offsets[1] + 'px'});
    
    if(position=='after')
      if(sortable.overlap == 'horizontal') 
        Sortable._marker.setStyle({left: (offsets[0]+dropon.clientWidth) + 'px'});
      else
        Sortable._marker.setStyle({top: (offsets[1]+dropon.clientHeight) + 'px'});
    
    Sortable._marker.show();
  },
  
  _tree: function(element, options, parent) {
    var children = Sortable.findElements(element, options) || [];
  
    for (var i = 0; i < children.length; ++i) {
      var match = children[i].id.match(options.format);

      if (!match) continue;
      
      var child = {
        id: encodeURIComponent(match ? match[1] : null),
        element: element,
        parent: parent,
        children: [],
        position: parent.children.length,
        container: $(children[i]).down(options.treeTag)
      }
      
      /* Get the element containing the children and recurse over it */
      if (child.container)
        this._tree(child.container, options, child)
      
      parent.children.push (child);
    }

    return parent; 
  },

  tree: function(element) {
    element = $(element);
    var sortableOptions = this.options(element);
    var options = Object.extend({
      tag: sortableOptions.tag,
      treeTag: sortableOptions.treeTag,
      only: sortableOptions.only,
      name: element.id,
      format: sortableOptions.format
    }, arguments[1] || {});
    
    var root = {
      id: null,
      parent: null,
      children: [],
      container: element,
      position: 0
    }
    
    return Sortable._tree(element, options, root);
  },

  /* Construct a [i] index for a particular node */
  _constructIndex: function(node) {
    var index = '';
    do {
      if (node.id) index = '[' + node.position + ']' + index;
    } while ((node = node.parent) != null);
    return index;
  },

  sequence: function(element) {
    element = $(element);
    var options = Object.extend(this.options(element), arguments[1] || {});
    
    return $(this.findElements(element, options) || []).map( function(item) {
      return item.id.match(options.format) ? item.id.match(options.format)[1] : '';
    });
  },

  setSequence: function(element, new_sequence) {
    element = $(element);
    var options = Object.extend(this.options(element), arguments[2] || {});
    
    var nodeMap = {};
    this.findElements(element, options).each( function(n) {
        if (n.id.match(options.format))
            nodeMap[n.id.match(options.format)[1]] = [n, n.parentNode];
        n.parentNode.removeChild(n);
    });
   
    new_sequence.each(function(ident) {
      var n = nodeMap[ident];
      if (n) {
        n[1].appendChild(n[0]);
        delete nodeMap[ident];
      }
    });
  },
  
  serialize: function(element) {
    element = $(element);
    var options = Object.extend(Sortable.options(element), arguments[1] || {});
    var name = encodeURIComponent(
      (arguments[1] && arguments[1].name) ? arguments[1].name : element.id);
    
    if (options.tree) {
      return Sortable.tree(element, arguments[1]).children.map( function (item) {
        return [name + Sortable._constructIndex(item) + "[id]=" + 
                encodeURIComponent(item.id)].concat(item.children.map(arguments.callee));
      }).flatten().join('&');
    } else {
      return Sortable.sequence(element, arguments[1]).map( function(item) {
        return name + "[]=" + encodeURIComponent(item);
      }).join('&');
    }
  }
}

// Returns true if child is contained within element
Element.isParent = function(child, element) {
  if (!child.parentNode || child == element) return false;
  if (child.parentNode == element) return true;
  return Element.isParent(child.parentNode, element);
}

Element.findChildren = function(element, only, recursive, tagName) {   
  if(!element.hasChildNodes()) return null;
  tagName = tagName.toUpperCase();
  if(only) only = [only].flatten();
  var elements = [];
  $A(element.childNodes).each( function(e) {
    if(e.tagName && e.tagName.toUpperCase()==tagName &&
      (!only || (Element.classNames(e).detect(function(v) { return only.include(v) }))))
        elements.push(e);
    if(recursive) {
      var grandchildren = Element.findChildren(e, only, recursive, tagName);
      if(grandchildren) elements.push(grandchildren);
    }
  });

  return (elements.length>0 ? elements.flatten() : []);
}

Element.offsetSize = function (element, type) {
  return element['offset' + ((type=='vertical' || type=='height') ? 'Height' : 'Width')];
}


// Copyright (c) 2005-2007 Thomas Fuchs (http://script.aculo.us, http://mir.aculo.us)
//           (c) 2005-2007 Ivan Krstic (http://blogs.law.harvard.edu/ivan)
//           (c) 2005-2007 Jon Tirsen (http://www.tirsen.com)
// Contributors:
//  Richard Livsey
//  Rahul Bhargava
//  Rob Wills
// 
// script.aculo.us is freely distributable under the terms of an MIT-style license.
// For details, see the script.aculo.us web site: http://script.aculo.us/

// Autocompleter.Base handles all the autocompletion functionality 
// that's independent of the data source for autocompletion. This
// includes drawing the autocompletion menu, observing keyboard
// and mouse events, and similar.
//
// Specific autocompleters need to provide, at the very least, 
// a getUpdatedChoices function that will be invoked every time
// the text inside the monitored textbox changes. This method 
// should get the text for which to provide autocompletion by
// invoking this.getToken(), NOT by directly accessing
// this.element.value. This is to allow incremental tokenized
// autocompletion. Specific auto-completion logic (AJAX, etc)
// belongs in getUpdatedChoices.
//
// Tokenized incremental autocompletion is enabled automatically
// when an autocompleter is instantiated with the 'tokens' option
// in the options parameter, e.g.:
// new Ajax.Autocompleter('id','upd', '/url/', { tokens: ',' });
// will incrementally autocomplete with a comma as the token.
// Additionally, ',' in the above example can be replaced with
// a token array, e.g. { tokens: [',', '\n'] } which
// enables autocompletion on multiple tokens. This is most 
// useful when one of the tokens is \n (a newline), as it 
// allows smart autocompletion after linebreaks.

if(typeof Effect == 'undefined')
  throw("controls.js requires including script.aculo.us' effects.js library");

var Autocompleter = {}
Autocompleter.Base = function() {};
Autocompleter.Base.prototype = {
  baseInitialize: function(element, update, options) {
    element          = $(element)
    this.element     = element; 
    this.update      = $(update);  
    this.hasFocus    = false; 
    this.changed     = false; 
    this.active      = false; 
    this.index       = 0;     
    this.entryCount  = 0;

    if(this.setOptions)
      this.setOptions(options);
    else
      this.options = options || {};

    this.options.paramName    = this.options.paramName || this.element.name;
    this.options.tokens       = this.options.tokens || [];
    this.options.frequency    = this.options.frequency || 0.4;
    this.options.minChars     = this.options.minChars || 1;
    this.options.onShow       = this.options.onShow || 
      function(element, update){ 
        if(!update.style.position || update.style.position=='absolute') {
          update.style.position = 'absolute';
          Position.clone(element, update, {
            setHeight: false, 
            offsetTop: element.offsetHeight
          });
        }
        Effect.Appear(update,{duration:0.15});
      };
    this.options.onHide = this.options.onHide || 
      function(element, update){ new Effect.Fade(update,{duration:0.15}) };

    if(typeof(this.options.tokens) == 'string') 
      this.options.tokens = new Array(this.options.tokens);

    this.observer = null;
    
    this.element.setAttribute('autocomplete','off');

    Element.hide(this.update);

    Event.observe(this.element, 'blur', this.onBlur.bindAsEventListener(this));
    Event.observe(this.element, 'keypress', this.onKeyPress.bindAsEventListener(this));

    // Turn autocomplete back on when the user leaves the page, so that the
    // field's value will be remembered on Mozilla-based browsers.
    Event.observe(window, 'beforeunload', function(){ 
      element.setAttribute('autocomplete', 'on'); 
    });
  },

  show: function() {
    if(Element.getStyle(this.update, 'display')=='none') this.options.onShow(this.element, this.update);
    if(!this.iefix && 
      (Prototype.Browser.IE) &&
      (Element.getStyle(this.update, 'position')=='absolute')) {
      new Insertion.After(this.update, 
       '<iframe id="' + this.update.id + '_iefix" '+
       'style="display:none;position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);" ' +
       'src="javascript:false;" frameborder="0" scrolling="no"></iframe>');
      this.iefix = $(this.update.id+'_iefix');
    }
    if(this.iefix) setTimeout(this.fixIEOverlapping.bind(this), 50);
  },
  
  fixIEOverlapping: function() {
    Position.clone(this.update, this.iefix, {setTop:(!this.update.style.height)});
    this.iefix.style.zIndex = 1;
    this.update.style.zIndex = 2;
    Element.show(this.iefix);
  },

  hide: function() {
    this.stopIndicator();
    if(Element.getStyle(this.update, 'display')!='none') this.options.onHide(this.element, this.update);
    if(this.iefix) Element.hide(this.iefix);
  },

  startIndicator: function() {
    if(this.options.indicator) Element.show(this.options.indicator);
  },

  stopIndicator: function() {
    if(this.options.indicator) Element.hide(this.options.indicator);
  },

  onKeyPress: function(event) {
    if(this.active)
      switch(event.keyCode) {
       case Event.KEY_TAB:
       case Event.KEY_RETURN:
         this.selectEntry();
         Event.stop(event);
       case Event.KEY_ESC:
         this.hide();
         this.active = false;
         Event.stop(event);
         return;
       case Event.KEY_LEFT:
       case Event.KEY_RIGHT:
         return;
       case Event.KEY_UP:
         this.markPrevious();
         this.render();
         if(Prototype.Browser.WebKit) Event.stop(event);
         return;
       case Event.KEY_DOWN:
         this.markNext();
         this.render();
         if(Prototype.Browser.WebKit) Event.stop(event);
         return;
      }
     else 
       if(event.keyCode==Event.KEY_TAB || event.keyCode==Event.KEY_RETURN || 
         (Prototype.Browser.WebKit > 0 && event.keyCode == 0)) return;

    this.changed = true;
    this.hasFocus = true;

    if(this.observer) clearTimeout(this.observer);
      this.observer = 
        setTimeout(this.onObserverEvent.bind(this), this.options.frequency*1000);
  },

  activate: function() {
    this.changed = false;
    this.hasFocus = true;
    this.getUpdatedChoices();
  },

  onHover: function(event) {
    var element = Event.findElement(event, 'LI');
    if(this.index != element.autocompleteIndex) 
    {
        this.index = element.autocompleteIndex;
        this.render();
    }
    Event.stop(event);
  },
  
  onClick: function(event) {
    var element = Event.findElement(event, 'LI');
    this.index = element.autocompleteIndex;
    this.selectEntry();
    this.hide();
  },
  
  onBlur: function(event) {
    // needed to make click events working
    setTimeout(this.hide.bind(this), 250);
    this.hasFocus = false;
    this.active = false;     
  }, 
  
  render: function() {
    if(this.entryCount > 0) {
      for (var i = 0; i < this.entryCount; i++)
        this.index==i ? 
          Element.addClassName(this.getEntry(i),"selected") : 
          Element.removeClassName(this.getEntry(i),"selected");
      if(this.hasFocus) { 
        this.show();
        this.active = true;
      }
    } else {
      this.active = false;
      this.hide();
    }
  },
  
  markPrevious: function() {
    if(this.index > 0) this.index--
      else this.index = this.entryCount-1;
    this.getEntry(this.index).scrollIntoView(true);
  },
  
  markNext: function() {
    if(this.index < this.entryCount-1) this.index++
      else this.index = 0;
    this.getEntry(this.index).scrollIntoView(false);
  },
  
  getEntry: function(index) {
    return this.update.firstChild.childNodes[index];
  },
  
  getCurrentEntry: function() {
    return this.getEntry(this.index);
  },
  
  selectEntry: function() {
    this.active = false;
    this.updateElement(this.getCurrentEntry());
  },

  updateElement: function(selectedElement) {
    if (this.options.updateElement) {
      this.options.updateElement(selectedElement);
      return;
    }
    var value = '';
    if (this.options.select) {
      var nodes = document.getElementsByClassName(this.options.select, selectedElement) || [];
      if(nodes.length>0) value = Element.collectTextNodes(nodes[0], this.options.select);
    } else
      value = Element.collectTextNodesIgnoreClass(selectedElement, 'informal');
    
    var lastTokenPos = this.findLastToken();
    if (lastTokenPos != -1) {
      var newValue = this.element.value.substr(0, lastTokenPos + 1);
      var whitespace = this.element.value.substr(lastTokenPos + 1).match(/^\s+/);
      if (whitespace)
        newValue += whitespace[0];
      this.element.value = newValue + value;
    } else {
      this.element.value = value;
    }
    this.element.focus();
    
    if (this.options.afterUpdateElement)
      this.options.afterUpdateElement(this.element, selectedElement);
  },

  updateChoices: function(choices) {
    if(!this.changed && this.hasFocus) {
      this.update.innerHTML = choices;
      Element.cleanWhitespace(this.update);
      Element.cleanWhitespace(this.update.down());

      if(this.update.firstChild && this.update.down().childNodes) {
        this.entryCount = 
          this.update.down().childNodes.length;
        for (var i = 0; i < this.entryCount; i++) {
          var entry = this.getEntry(i);
          entry.autocompleteIndex = i;
          this.addObservers(entry);
        }
      } else { 
        this.entryCount = 0;
      }

      this.stopIndicator();
      this.index = 0;
      
      if(this.entryCount==1 && this.options.autoSelect) {
        this.selectEntry();
        this.hide();
      } else {
        this.render();
      }
    }
  },

  addObservers: function(element) {
    Event.observe(element, "mouseover", this.onHover.bindAsEventListener(this));
    Event.observe(element, "click", this.onClick.bindAsEventListener(this));
  },

  onObserverEvent: function() {
    this.changed = false;   
    if(this.getToken().length>=this.options.minChars) {
      this.getUpdatedChoices();
    } else {
      this.active = false;
      this.hide();
    }
  },

  getToken: function() {
    var tokenPos = this.findLastToken();
    if (tokenPos != -1)
      var ret = this.element.value.substr(tokenPos + 1).replace(/^\s+/,'').replace(/\s+$/,'');
    else
      var ret = this.element.value;

    return /\n/.test(ret) ? '' : ret;
  },

  findLastToken: function() {
    var lastTokenPos = -1;

    for (var i=0; i<this.options.tokens.length; i++) {
      var thisTokenPos = this.element.value.lastIndexOf(this.options.tokens[i]);
      if (thisTokenPos > lastTokenPos)
        lastTokenPos = thisTokenPos;
    }
    return lastTokenPos;
  }
}

Ajax.Autocompleter = Class.create();
Object.extend(Object.extend(Ajax.Autocompleter.prototype, Autocompleter.Base.prototype), {
  initialize: function(element, update, url, options) {
    this.baseInitialize(element, update, options);
    this.options.asynchronous  = true;
    this.options.onComplete    = this.onComplete.bind(this);
    this.options.defaultParams = this.options.parameters || null;
    this.url                   = url;
  },

  getUpdatedChoices: function() {
    this.startIndicator();
    
    var entry = encodeURIComponent(this.options.paramName) + '=' + 
      encodeURIComponent(this.getToken());

    this.options.parameters = this.options.callback ?
      this.options.callback(this.element, entry) : entry;

    if(this.options.defaultParams) 
      this.options.parameters += '&' + this.options.defaultParams;
    
    new Ajax.Request(this.url, this.options);
  },

  onComplete: function(request) {
    this.updateChoices(request.responseText);
  }

});

// The local array autocompleter. Used when you'd prefer to
// inject an array of autocompletion options into the page, rather
// than sending out Ajax queries, which can be quite slow sometimes.
//
// The constructor takes four parameters. The first two are, as usual,
// the id of the monitored textbox, and id of the autocompletion menu.
// The third is the array you want to autocomplete from, and the fourth
// is the options block.
//
// Extra local autocompletion options:
// - choices - How many autocompletion choices to offer
//
// - partialSearch - If false, the autocompleter will match entered
//                    text only at the beginning of strings in the 
//                    autocomplete array. Defaults to true, which will
//                    match text at the beginning of any *word* in the
//                    strings in the autocomplete array. If you want to
//                    search anywhere in the string, additionally set
//                    the option fullSearch to true (default: off).
//
// - fullSsearch - Search anywhere in autocomplete array strings.
//
// - partialChars - How many characters to enter before triggering
//                   a partial match (unlike minChars, which defines
//                   how many characters are required to do any match
//                   at all). Defaults to 2.
//
// - ignoreCase - Whether to ignore case when autocompleting.
//                 Defaults to true.
//
// It's possible to pass in a custom function as the 'selector' 
// option, if you prefer to write your own autocompletion logic.
// In that case, the other options above will not apply unless
// you support them.

Autocompleter.Local = Class.create();
Autocompleter.Local.prototype = Object.extend(new Autocompleter.Base(), {
  initialize: function(element, update, array, options) {
    this.baseInitialize(element, update, options);
    this.options.array = array;
  },

  getUpdatedChoices: function() {
    this.updateChoices(this.options.selector(this));
  },

  setOptions: function(options) {
    this.options = Object.extend({
      choices: 10,
      partialSearch: true,
      partialChars: 2,
      ignoreCase: true,
      fullSearch: false,
      selector: function(instance) {
        var ret       = []; // Beginning matches
        var partial   = []; // Inside matches
        var entry     = instance.getToken();
        var count     = 0;

        for (var i = 0; i < instance.options.array.length &&  
          ret.length < instance.options.choices ; i++) { 

          var elem = instance.options.array[i];
          var foundPos = instance.options.ignoreCase ? 
            elem.toLowerCase().indexOf(entry.toLowerCase()) : 
            elem.indexOf(entry);

          while (foundPos != -1) {
            if (foundPos == 0 && elem.length != entry.length) { 
              ret.push("<li><strong>" + elem.substr(0, entry.length) + "</strong>" + 
                elem.substr(entry.length) + "</li>");
              break;
            } else if (entry.length >= instance.options.partialChars && 
              instance.options.partialSearch && foundPos != -1) {
              if (instance.options.fullSearch || /\s/.test(elem.substr(foundPos-1,1))) {
                partial.push("<li>" + elem.substr(0, foundPos) + "<strong>" +
                  elem.substr(foundPos, entry.length) + "</strong>" + elem.substr(
                  foundPos + entry.length) + "</li>");
                break;
              }
            }

            foundPos = instance.options.ignoreCase ? 
              elem.toLowerCase().indexOf(entry.toLowerCase(), foundPos + 1) : 
              elem.indexOf(entry, foundPos + 1);

          }
        }
        if (partial.length)
          ret = ret.concat(partial.slice(0, instance.options.choices - ret.length))
        return "<ul>" + ret.join('') + "</ul>";
      }
    }, options || {});
  }
});

// AJAX in-place editor
//
// see documentation on http://wiki.script.aculo.us/scriptaculous/show/Ajax.InPlaceEditor

// Use this if you notice weird scrolling problems on some browsers,
// the DOM might be a bit confused when this gets called so do this
// waits 1 ms (with setTimeout) until it does the activation
Field.scrollFreeActivate = function(field) {
  setTimeout(function() {
    Field.activate(field);
  }, 1);
}

Ajax.InPlaceEditor = Class.create();
Ajax.InPlaceEditor.defaultHighlightColor = "#FFFF99";
Ajax.InPlaceEditor.prototype = {
  initialize: function(element, url, options) {
    this.url = url;
    this.element = $(element);

    this.options = Object.extend({
      paramName: "value",
      okButton: true,
      okLink: false,
      okText: "ok",
      cancelButton: false,
      cancelLink: true,
      cancelText: "cancel",
      textBeforeControls: '',
      textBetweenControls: '',
      textAfterControls: '',
      savingText: "Saving...",
      clickToEditText: "Click to edit",
      okText: "ok",
      rows: 1,
      onComplete: function(transport, element) {
        new Effect.Highlight(element, {startcolor: this.options.highlightcolor});
      },
      onFailure: function(transport) {
        alert("Error communicating with the server: " + transport.responseText.stripTags());
      },
      callback: function(form) {
        return Form.serialize(form);
      },
      handleLineBreaks: true,
      loadingText: 'Loading...',
      savingClassName: 'inplaceeditor-saving',
      loadingClassName: 'inplaceeditor-loading',
      formClassName: 'inplaceeditor-form',
      highlightcolor: Ajax.InPlaceEditor.defaultHighlightColor,
      highlightendcolor: "#FFFFFF",
      externalControl: null,
      submitOnBlur: false,
      ajaxOptions: {},
      evalScripts: false
    }, options || {});

    if(!this.options.formId && this.element.id) {
      this.options.formId = this.element.id + "-inplaceeditor";
      if ($(this.options.formId)) {
        // there's already a form with that name, don't specify an id
        this.options.formId = null;
      }
    }
    
    if (this.options.externalControl) {
      this.options.externalControl = $(this.options.externalControl);
    }
    
    this.originalBackground = Element.getStyle(this.element, 'background-color');
    if (!this.originalBackground) {
      this.originalBackground = "transparent";
    }
    
    this.element.title = this.options.clickToEditText;
    
    this.onclickListener = this.enterEditMode.bindAsEventListener(this);
    this.mouseoverListener = this.enterHover.bindAsEventListener(this);
    this.mouseoutListener = this.leaveHover.bindAsEventListener(this);
    Event.observe(this.element, 'click', this.onclickListener);
    Event.observe(this.element, 'mouseover', this.mouseoverListener);
    Event.observe(this.element, 'mouseout', this.mouseoutListener);
    if (this.options.externalControl) {
      Event.observe(this.options.externalControl, 'click', this.onclickListener);
      Event.observe(this.options.externalControl, 'mouseover', this.mouseoverListener);
      Event.observe(this.options.externalControl, 'mouseout', this.mouseoutListener);
    }
  },
  enterEditMode: function(evt) {
    if (this.saving) return;
    if (this.editing) return;
    this.editing = true;
    this.onEnterEditMode();
    if (this.options.externalControl) {
      Element.hide(this.options.externalControl);
    }
    Element.hide(this.element);
    this.createForm();
    this.element.parentNode.insertBefore(this.form, this.element);
    if (!this.options.loadTextURL) Field.scrollFreeActivate(this.editField);
    // stop the event to avoid a page refresh in Safari
    if (evt) {
      Event.stop(evt);
    }
    return false;
  },
  createForm: function() {
    this.form = document.createElement("form");
    this.form.id = this.options.formId;
    Element.addClassName(this.form, this.options.formClassName)
    this.form.onsubmit = this.onSubmit.bind(this);

    this.createEditField();

    if (this.options.textarea) {
      var br = document.createElement("br");
      this.form.appendChild(br);
    }
    
    if (this.options.textBeforeControls)
      this.form.appendChild(document.createTextNode(this.options.textBeforeControls));

    if (this.options.okButton) {
      var okButton = document.createElement("input");
      okButton.type = "submit";
      okButton.value = this.options.okText;
      okButton.className = 'editor_ok_button';
      this.form.appendChild(okButton);
    }
    
    if (this.options.okLink) {
      var okLink = document.createElement("a");
      okLink.href = "#";
      okLink.appendChild(document.createTextNode(this.options.okText));
      okLink.onclick = this.onSubmit.bind(this);
      okLink.className = 'editor_ok_link';
      this.form.appendChild(okLink);
    }
    
    if (this.options.textBetweenControls && 
      (this.options.okLink || this.options.okButton) && 
      (this.options.cancelLink || this.options.cancelButton))
      this.form.appendChild(document.createTextNode(this.options.textBetweenControls));
      
    if (this.options.cancelButton) {
      var cancelButton = document.createElement("input");
      cancelButton.type = "submit";
      cancelButton.value = this.options.cancelText;
      cancelButton.onclick = this.onclickCancel.bind(this);
      cancelButton.className = 'editor_cancel_button';
      this.form.appendChild(cancelButton);
    }

    if (this.options.cancelLink) {
      var cancelLink = document.createElement("a");
      cancelLink.href = "#";
      cancelLink.appendChild(document.createTextNode(this.options.cancelText));
      cancelLink.onclick = this.onclickCancel.bind(this);
      cancelLink.className = 'editor_cancel editor_cancel_link';      
      this.form.appendChild(cancelLink);
    }
    
    if (this.options.textAfterControls)
      this.form.appendChild(document.createTextNode(this.options.textAfterControls));
  },
  hasHTMLLineBreaks: function(string) {
    if (!this.options.handleLineBreaks) return false;
    return string.match(/<br/i) || string.match(/<p>/i);
  },
  convertHTMLLineBreaks: function(string) {
    return string.replace(/<br>/gi, "\n").replace(/<br\/>/gi, "\n").replace(/<\/p>/gi, "\n").replace(/<p>/gi, "");
  },
  createEditField: function() {
    var text;
    if(this.options.loadTextURL) {
      text = this.options.loadingText;
    } else {
      text = this.getText();
    }

    var obj = this;
    
    if (this.options.rows == 1 && !this.hasHTMLLineBreaks(text)) {
      this.options.textarea = false;
      var textField = document.createElement("input");
      textField.obj = this;
      textField.type = "text";
      textField.name = this.options.paramName;
      textField.value = text;
      textField.style.backgroundColor = this.options.highlightcolor;
      textField.className = 'editor_field';
      var size = this.options.size || this.options.cols || 0;
      if (size != 0) textField.size = size;
      if (this.options.submitOnBlur)
        textField.onblur = this.onSubmit.bind(this);
      this.editField = textField;
    } else {
      this.options.textarea = true;
      var textArea = document.createElement("textarea");
      textArea.obj = this;
      textArea.name = this.options.paramName;
      textArea.value = this.convertHTMLLineBreaks(text);
      textArea.rows = this.options.rows;
      textArea.cols = this.options.cols || 40;
      textArea.className = 'editor_field';      
      if (this.options.submitOnBlur)
        textArea.onblur = this.onSubmit.bind(this);
      this.editField = textArea;
    }
    
    if(this.options.loadTextURL) {
      this.loadExternalText();
    }
    this.form.appendChild(this.editField);
  },
  getText: function() {
    return this.element.innerHTML;
  },
  loadExternalText: function() {
    Element.addClassName(this.form, this.options.loadingClassName);
    this.editField.disabled = true;
    new Ajax.Request(
      this.options.loadTextURL,
      Object.extend({
        asynchronous: true,
        onComplete: this.onLoadedExternalText.bind(this)
      }, this.options.ajaxOptions)
    );
  },
  onLoadedExternalText: function(transport) {
    Element.removeClassName(this.form, this.options.loadingClassName);
    this.editField.disabled = false;
    this.editField.value = transport.responseText.stripTags();
    Field.scrollFreeActivate(this.editField);
  },
  onclickCancel: function() {
    this.onComplete();
    this.leaveEditMode();
    return false;
  },
  onFailure: function(transport) {
    this.options.onFailure(transport);
    if (this.oldInnerHTML) {
      this.element.innerHTML = this.oldInnerHTML;
      this.oldInnerHTML = null;
    }
    return false;
  },
  onSubmit: function() {
    // onLoading resets these so we need to save them away for the Ajax call
    var form = this.form;
    var value = this.editField.value;
    
    // do this first, sometimes the ajax call returns before we get a chance to switch on Saving...
    // which means this will actually switch on Saving... *after* we've left edit mode causing Saving...
    // to be displayed indefinitely
    this.onLoading();
    
    if (this.options.evalScripts) {
      new Ajax.Request(
        this.url, Object.extend({
          parameters: this.options.callback(form, value),
          onComplete: this.onComplete.bind(this),
          onFailure: this.onFailure.bind(this),
          asynchronous:true, 
          evalScripts:true
        }, this.options.ajaxOptions));
    } else  {
      new Ajax.Updater(
        { success: this.element,
          // don't update on failure (this could be an option)
          failure: null }, 
        this.url, Object.extend({
          parameters: this.options.callback(form, value),
          onComplete: this.onComplete.bind(this),
          onFailure: this.onFailure.bind(this)
        }, this.options.ajaxOptions));
    }
    // stop the event to avoid a page refresh in Safari
    if (arguments.length > 1) {
      Event.stop(arguments[0]);
    }
    return false;
  },
  onLoading: function() {
    this.saving = true;
    this.removeForm();
    this.leaveHover();
    this.showSaving();
  },
  showSaving: function() {
    this.oldInnerHTML = this.element.innerHTML;
    this.element.innerHTML = this.options.savingText;
    Element.addClassName(this.element, this.options.savingClassName);
    this.element.style.backgroundColor = this.originalBackground;
    Element.show(this.element);
  },
  removeForm: function() {
    if(this.form) {
      if (this.form.parentNode) Element.remove(this.form);
      this.form = null;
    }
  },
  enterHover: function() {
    if (this.saving) return;
    this.element.style.backgroundColor = this.options.highlightcolor;
    if (this.effect) {
      this.effect.cancel();
    }
    Element.addClassName(this.element, this.options.hoverClassName)
  },
  leaveHover: function() {
    if (this.options.backgroundColor) {
      this.element.style.backgroundColor = this.oldBackground;
    }
    Element.removeClassName(this.element, this.options.hoverClassName)
    if (this.saving) return;
    this.effect = new Effect.Highlight(this.element, {
      startcolor: this.options.highlightcolor,
      endcolor: this.options.highlightendcolor,
      restorecolor: this.originalBackground
    });
  },
  leaveEditMode: function() {
    Element.removeClassName(this.element, this.options.savingClassName);
    this.removeForm();
    this.leaveHover();
    this.element.style.backgroundColor = this.originalBackground;
    Element.show(this.element);
    if (this.options.externalControl) {
      Element.show(this.options.externalControl);
    }
    this.editing = false;
    this.saving = false;
    this.oldInnerHTML = null;
    this.onLeaveEditMode();
  },
  onComplete: function(transport) {
    this.leaveEditMode();
    this.options.onComplete.bind(this)(transport, this.element);
  },
  onEnterEditMode: function() {},
  onLeaveEditMode: function() {},
  dispose: function() {
    if (this.oldInnerHTML) {
      this.element.innerHTML = this.oldInnerHTML;
    }
    this.leaveEditMode();
    Event.stopObserving(this.element, 'click', this.onclickListener);
    Event.stopObserving(this.element, 'mouseover', this.mouseoverListener);
    Event.stopObserving(this.element, 'mouseout', this.mouseoutListener);
    if (this.options.externalControl) {
      Event.stopObserving(this.options.externalControl, 'click', this.onclickListener);
      Event.stopObserving(this.options.externalControl, 'mouseover', this.mouseoverListener);
      Event.stopObserving(this.options.externalControl, 'mouseout', this.mouseoutListener);
    }
  }
};

Ajax.InPlaceCollectionEditor = Class.create();
Object.extend(Ajax.InPlaceCollectionEditor.prototype, Ajax.InPlaceEditor.prototype);
Object.extend(Ajax.InPlaceCollectionEditor.prototype, {
  createEditField: function() {
    if (!this.cached_selectTag) {
      var selectTag = document.createElement("select");
      var collection = this.options.collection || [];
      var optionTag;
      collection.each(function(e,i) {
        optionTag = document.createElement("option");
        optionTag.value = (e instanceof Array) ? e[0] : e;
        if((typeof this.options.value == 'undefined') && 
          ((e instanceof Array) ? this.element.innerHTML == e[1] : e == optionTag.value)) optionTag.selected = true;
        if(this.options.value==optionTag.value) optionTag.selected = true;
        optionTag.appendChild(document.createTextNode((e instanceof Array) ? e[1] : e));
        selectTag.appendChild(optionTag);
      }.bind(this));
      this.cached_selectTag = selectTag;
    }

    this.editField = this.cached_selectTag;
    if(this.options.loadTextURL) this.loadExternalText();
    this.form.appendChild(this.editField);
    this.options.callback = function(form, value) {
      return "value=" + encodeURIComponent(value);
    }
  }
});

// Delayed observer, like Form.Element.Observer, 
// but waits for delay after last key input
// Ideal for live-search fields

Form.Element.DelayedObserver = Class.create();
Form.Element.DelayedObserver.prototype = {
  initialize: function(element, delay, callback) {
    this.delay     = delay || 0.5;
    this.element   = $(element);
    this.callback  = callback;
    this.timer     = null;
    this.lastValue = $F(this.element); 
    Event.observe(this.element,'keyup',this.delayedListener.bindAsEventListener(this));
  },
  delayedListener: function(event) {
    if(this.lastValue == $F(this.element)) return;
    if(this.timer) clearTimeout(this.timer);
    this.timer = setTimeout(this.onTimerEvent.bind(this), this.delay * 1000);
    this.lastValue = $F(this.element);
  },
  onTimerEvent: function() {
    this.timer = null;
    this.callback(this.element, $F(this.element));
  }
};


/* ------------------------------------------------------------------------
 * application.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

/* Add support for specifying a Selector for containment */

Object.extend(Droppables, {
  add: Droppables.add.wrap(function(proceed, element) {
    var options = arguments[2] || {}, containment = options.containment;
    
    if (containment && containment.expression && containment.match) {
      Droppables._containers_by_expression = Droppables._containers_by_expression || {};
      options._container_selector = containment;
      options._containers = 'selector';
      options.containment = null;
    }
    
    return proceed(element, options);
  }),
  
  isContained: Droppables.isContained.wrap(function(proceed, element, drop) {
    if (drop._container_selector && drop._containers == 'selector') {
      var selector = drop._container_selector, containers = Droppables._containers_by_expression;
      if (!containers[selector.expression]) 
        containers[selector.expression] = selector.findElements();
      drop._containers = containers[selector.expression];
    }
    
    return proceed(element, drop);
  }),
  
  reset: Droppables.reset.wrap(function(proceed) {
    Droppables._containers_by_expression = {};
    
    this.drops.each(function(drop) {
      if (drop._container_selector)
        drop._containers = 'selector';
    });
    
    return proceed();
  })
});

/*--------------------------------------------------------------------------*/

Widget = {
  beforeDragRequestHandlers: [],
  
  serialize: function(widget) {
    widget = $(widget || 'widgets');
    var elements = Selector.matchElements(widget.immediateDescendants(), 'div.widget');
    return elements.invoke('readAttribute', 'record').map(function(record) {
      return 'records[]=' + encodeURIComponent(record);
    }).join('&');
  },
  
  makeDragRequest: function(url, container) {
    container = $(container);
    var widget = Draggables.activeDraggable.element;
    var widgetParent = widget.up('div.widget_parent');
    if (widgetParent != container) return;
    
    for (var i = 0, length = Widget.beforeDragRequestHandlers.length; i < length; i++)
      if (!Widget.beforeDragRequestHandlers[i](widget, widgetParent)) return false;
    
    new Ajax.Request(url, {
      parameters: $H({
        container: (container.up('div.widget') || container.up('div.page.content')).id,
        record: widget.getAttribute('record')
      }).toQueryString() + '&' + Widget.serialize(container)
    });
  },
  
  onItemEditKeyPress: function(event) {
    element = Event.element(event);
    if (event.keyCode == 13) {
      element.up('form').onsubmit();
      Event.stop(event);
    }
  },
  
  ifWidgetHasNoChildren: function(widget, callback) {
    widget = $(widget);
    if (!widget.down('div.widget', 1)) callback();
  }
};

Draggables.addObserver({
  onStart: function(eventName, draggable, event) {
    if (window.Nubbins) Nubbins.stop();
  },
  
  onEnd: function(eventName, draggable, event) {
    if (window.Nubbins) Nubbins.start();
  }
});

var Sortables = Sortable;

/*--------------------------------------------------------------------------*/

var Enumerator = Class.create();
Object.extend(Enumerator.prototype, Enumerable);
Object.extend(Enumerator.prototype, (function() {
  var values = [], value, options;

  function isFirst() {
    return values.length == 0;
  }

  function next(index) {
    value = isFirst() ? options.first() : options.next(value, index);
    values.push(value);
    return value;
  }

  return {
    initialize: function(_options) {
      options = _options;
    },
    
    _each: function(iterator) {
      if (isFirst()) {
        var index = 0;
        while (true) iterator(next(index++));      
      } else {
        values.each(iterator);
      }
    },
  
    backgroundEach: function(iterator, options) {
      options = options || {};
      var index = 0, performIteration = function() {
        try {
          iterator(next(index), index);
          performIteration.defer();
          index++;
        } catch (e) {
          if (e != $break) throw e;
          if (options.afterFinish) options.afterFinish.defer();
        }
      };
      performIteration.defer();
    },
  
    reset: function() {
      values.clear();
    }
  };
})());

/* Wraps an Enumerable in an Enumerator */

function $E(enumerable) {
  var values = enumerable.toArray();
  
  return new Enumerator({
    first: function() { 
      if (!values.length) throw $break;
      return values.first(); 
    },
    
    next:  function(value, index) { 
      if (index >= values.length) throw $break;
      return values[index];
    }
  });
}

/*--------------------------------------------------------------------------*/

Element.addMethods({
  getStyle: function(element, style) {
    element = $(element);
    style = style == 'float' ? 'cssFloat' : style.camelize();
    var value = element.style[style];
    if (style == 'opacity') return value ? parseFloat(value) : 1.0;
    return value == 'auto' ? null : value;
  }
});

/* Preload these images */

Event.observe(window, 'load', function() {
  var all = $$('link[href*="/all.css"]'), domain = '';

  if (all.length > 0) {
    url = all.first().readAttribute('href').match(/:(\/\/.*?)\//);
    if (url) domain = url[1];
  }
  
  if (domain != '' && domain != null) {
    ["/images/post_a_new_message-pressed.gif",
     "/images/add_a_new_milestone-pressed.gif",
  	 "/images/new_project-pressed.gif",
     "/images/create_a_writeboard-pressed.gif",
     "/images/new_to-do_list-pressed.gif",
     "/images/upload_a_file-pressed.gif",
     "/images/upload_a_new_version-pressed.gif",
     "/images/nubbin.gif",
     "/images/drag_handle.gif",
     "/images/trash.gif"].each(function(path) {
       new Image().src = domain + path;
    });
  }
});

/* Enable nubbins */

Event.observe(window, "load", function() {
  if (Prototype.Browser.MobileSafari)
    $(document.body).addClassName("iphone");
    
  if ($(document.body).hasClassName("nubbins")) {
    window.Nubbins = new HoverObserver("screen_body");
  }
});

/* Unfold anchored sheets automatically */

Event.observe(window, 'load', function() {
  if (window.location.hash) {
    var element = $(window.location.hash.substr(1));
    if (element && element.hasClassName('sheet')) {
      Layout.swapWithScreenBody(element);
    }
  }
});

/* Process after-load callbacks */

window.afterLoad = [];

Event.observe(window, 'load', function() {
  if (window.afterLoad.length) {
    (function() {
      $E(window.afterLoad).backgroundEach(function(callback) {
        callback();
      });
    }).delay(0.25);
  }
});


/* ------------------------------------------------------------------------
 * calendar_date_select.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

Element.addMethods({
  clear: function(element) {
    element = $(element);
    for (var i = 0, length = element.childNodes.length, node; i < length; i++)
      element.removeChild(element.childNodes[i]);
    return element;
  },
  
  setText: function(element, value) {
    element = $(element);
    var node = document.createTextNode(value);
    element.clear().appendChild(node);
    return element;
  }
});

var CalendarDateSelect = Class.create();
CalendarDateSelect.prototype = {
  initialize: function(field, options) {
    this.field     = $(field);
    this.selection = $D(this.field.value);
    this.options   = options || {};
    this.dayMap    = eval(this.options.map || {});
    this.createElement();
    this.setCursor(this.selection);
    this.field.insert({ after: this.element });
  },
  
  createElement: function() {
    var container = document.createElement("div");
    container.className = "calendar_date_select";
    
    container.appendChild(this.createHeader());
    container.appendChild(this.createBody());
    container.appendChild(this.createFooter());
    
    return this.element = $(container);
  },
  
  createHeader: function() {
    var header = document.createElement("div");
    header.className = "header";
    
    var previousLink = document.createElement("a");
    previousLink.className = "nav left";
    previousLink.href = "#";
    previousLink.innerHTML = "<<".escapeHTML();
    previousLink.onclick = this.previous.bind(this);
    
    var nextLink = document.createElement("a");
    nextLink.className = "nav right";
    nextLink.href = "#";
    nextLink.innerHTML = ">>".escapeHTML();
    nextLink.onclick = this.next.bind(this);
    
    header.appendChild(previousLink);
    header.appendChild(nextLink);
    header.appendChild(this.createSelect());
    
    return this.header = $(header);
  },

  dateToIndex: function(date) {
    var months = date.getFullYear() * 12 + date.getMonth();
    return months - this.pivot;
  },

  indexToDate: function(index) {
    index = this.pivot + index;
    var month = index % 12;
    var year  = parseInt(index / 12);
    return new Date(year, month, 1);
  },

  createSelect: function() {
    this.monthSelect = document.createElement("select");
    this.monthSelect.className = "months";
    this.monthSelect.onchange = this.updateFromSelect.bind(this);

    var date = this.selection;
    var today = $D();
    if (date > today) date = today;

    this.pivot = date.getFullYear() * 12 + date.getMonth() - 12;

    var index = 0;
    while (index < 48) {
      var date = this.indexToDate(index);
      var text = date.getMonthName().substring(0, 3) + " " + date.getFullYear();
      this.monthSelect.options[index] = new Option(text);
      index += 1;
    }
    return this.monthSelect;
  },

  updateFromSelect: function() {
    var date = this.indexToDate(this.monthSelect.selectedIndex);
    this.setCursor(date);
  },

  createBody: function() {
    var body = document.createElement("div");
    body.className = "body";
    return this.body = $(body);
  },
  
  createFooter: function() {
    var footer = document.createElement("div");
    footer.className = "footer";
    
    var prompt = document.createElement("span");
    prompt.className = "prompt";
    prompt.innerHTML = "Due:&nbsp;";
    footer.appendChild(prompt);
    
    var selectionText = document.createElement("span");
    selectionText.className = "selection";
    this.selectionText = $(selectionText);
    this.updateSelectionText();
    footer.appendChild(selectionText);
    
    return this.footer = $(footer);
  },
  
  onDateChanged: function(date) {
    this.selection = date;
    this.field.value = date.toDateString();
    this.updateSelectionText();
    if(this.options.onchange) eval(this.options.onchange);
  },
  
  updateGrid: function() {
    this.grid = new CalendarDateSelect.Grid(this.selection, this.cursor, {
      onDateChanged: this.onDateChanged.bind(this),
      dayMap: this.dayMap
    });
    this.body.clear();
    this.body.appendChild(this.grid.element);
  },
  
  updateMonthSelect: function() {
    this.monthSelect.selectedIndex = this.dateToIndex(this.cursor);
  },
  
  updateSelectionText: function() {
    this.selectionText.setText(this.selection.getMonthName() + " " + 
      this.selection.getDate() + ", " + this.selection.getFullYear());
  },
  
  setCursor: function(date) {
    if(this.allowNavigateToDate(date)) {
      this.cursor = date.beginningOfMonth();
      this.updateGrid();
      this.updateMonthSelect();
    }
  },
  
  previous: function() {
    var previousMonth = this.cursor.previous().beginningOfMonth();
    this.setCursor(previousMonth);
    return false;
  },
  
  next: function() {
    var month = this.cursor.getMonth() + 1, year = this.cursor.getFullYear();
    if (month > 11) month = 0, year++;
    this.setCursor(new Date(year, month));
    return false;
  },

  allowNavigateToDate: function(date) {
    var index = this.dateToIndex(date);
    if (index < 0 || index >= this.monthSelect.options.length) {
      return false;
    }
    return true;
  }
};

CalendarDateSelect.Grid = Class.create();
CalendarDateSelect.Grid.prototype = {
  initialize: function(selection, cursor, options) {
    this.selection = $D(selection);
    this.cursor    = $D(cursor).beginningOfMonth();
    this.today     = $D();
    this.options   = options || {};
    this.dayMap    = options.dayMap || {};
    this.createElement();
  },
  
  getStartDate: function() {
    return this.cursor.beginningOfWeek();
  },
  
  getEndDate: function() {
    return this.getStartDate().next(41);
  },
  
  getDates: function() {
    return $R(this.getStartDate(), this.getEndDate());
  },
  
  getWeeks: function() {
    return this.getDates().inGroupsOf(7);
  },
  
  getClassNamesForDate: function(date) {
    var classNames = [];
    var time = date.getTime();

    if (date.equal(this.today))     classNames.push("today");
    if (date.equal(this.selection)) classNames.push("selected");
    if (date.isWeekend())           classNames.push("weekend");
    if (!date.beginningOfMonth().equal(this.cursor))
      classNames.push("other");
      
    if (this.dayMap[time]) classNames.push(this.dayMap[time])

    return classNames;
  },
  
  selectDate: function(element, date) {
    var selection = this.element.down("td.selected");
    if (selection) selection.removeClassName("selected");
    
    this.selectedElement = $(element);
    element.addClassName("selected");
    
    this.date = date;
    if (this.options.onDateChanged) this.options.onDateChanged(date);
    
    return false;
  },
  
  createElement: function() {
    var table = document.createElement("table");
    var tbody = document.createElement("tbody");
    
    var weekdays = document.createElement("tr");
    weekdays.className = "weekdays";
    
    Date.WEEKDAYS.each(function(day) {
      var th = document.createElement("th");
      th.innerHTML = day.charAt(0);
      weekdays.appendChild(th);
    });
    
    tbody.appendChild(weekdays);
    
    this.getWeeks().each(function(week) {
      var tr = document.createElement("tr");
      tr.className = "days";
      
      week.each(function(date) {
        var classNames = this.getClassNamesForDate(date);

        var td = document.createElement("td");
        if (classNames.include("today")) this.selectedElement = td;
        td.className = classNames.join(" ");
        
        var a = document.createElement("a");
        a.href = "#";
        a.innerHTML = date.getDate();
        a.onclick = this.selectDate.bind(this, td, date);
        
        td.appendChild(a);        
        tr.appendChild(td);
      }.bind(this));
      
      tbody.appendChild(tr);
    }.bind(this));
    
    table.appendChild(tbody);
    return this.element = $(table);
  }
};



/* ------------------------------------------------------------------------
 * categories.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

categories = {
  toggleEdit: function() {
    if($('edit_categories_link')['bc:active']) {
      Element.activate('edit_categories_link', false)
      $('CategoryList').removeClassName("editing")
    } else {
      Element.activate('edit_categories_link', true)
      $('CategoryList').addClassName("editing")
    }
    $('add_new_category').toggle();
  },

  toggleOperationSpinner: function(id) {
    Element.toggle('operation_wait_' + id,
      'operation_rename_' + id, 'operation_delete_' + id)
  },

  cancelEdit: function(id) {
    $('edit_category_' + id).remove()
    $('category_menu_item_' + id).show()
  },

  edit: function(id, name, url) {
    name = prompt("Rename this category", name);
    if(name) {
      this.toggleOperationSpinner(id);
      new Ajax.Request(url, {asynchronous:true, evalScripts:true,
        parameters:'name=' + encodeURIComponent(name),
        onFailure: function(req) { categorySelect.addFailed(req) }
      });
    }
  },

  addNew: function() {
    toggle = function() { $('add_new_category_link', 'add_new_category_spinner').each(Element.toggle); };
    categories.add({ addFailed: toggle, validName: toggle });
  },

  add: function(options) {
    options = options || {};
    var name = prompt("Enter the new category name:", "");
    if(name) name = name.strip()
    if(!name || name.length < 1) {
      if(options.invalidName) options.invalidName();
    } else {
      if(options.validName) options.validName(name);
      new Ajax.Request(this.url, {asynchronous:true, evalScripts:true,
        parameters:'name=' + encodeURIComponent(name),
        onFailure: function(req) { categories.addFailed(req, options); }
      });
    }
  },

  addFailed: function(request, options) {
    alert("An error prevented the category from being added. Please try again.")
    if(options.addFailed) options.addFailed(req);
  }
}

categorySelect = {
  controls: [],
  allowNone: false,

  register: function(id) {
    var control = $(id)
    this.controls.push(control)
    Event.observe(control, 'change', this.detectChange.bind(this))
  },

  detectChange: function(event) {
    var control = Event.element(event)
    if(control.selectedIndex == control.options.length - 1) {
      categories.add({
        invalidName: function() {
          control.selectedIndex = 0;
        },

        validName: function(name) {
          categorySelect.control = control
          categorySelect.enableControls(false)
        },

        addFailed: function(req) {
          categorySelect.enableControls(true)
          categorySelect.control.selectedIndex = 0
       }
      });
    }
  },

  enableControls: function(setting) {
    this.controls.each(function(item) {
      item.disabled = !setting;
    })
  },

  addCategory: function(id, name, position) {
    if(this.allowNone) position++
    this.controls.each(function(item){
      var options = $A(item.options)
      options.splice(position, 0, new Option(name, id))
      for(var idx = 0; idx < options.length; idx++) {
        item.options[idx] = options[idx]
      }
    })
    this.reset(position);
  },

  reset: function(selected) {
    if(this.control) this.control.selectedIndex = (selected || 0);
    this.enableControls(true)
  },

  renameCategory: function(id, name) {
    this.controls.each(function(item){
      for(var idx = 0; idx < item.options.length; idx++) {
        if(parseInt(item.options[idx].value) == id) {
          item.options[idx].text = name;
          break;
        }
      }
    })
  },

  deleteCategory: function(id) {
    this.controls.each(function(item){
      for(var idx = 0; idx < item.options.length; idx++)
        if(parseInt(item.options[idx].value) == id) {
          item.options[idx] = null;
          break;
        }
    })
  }
}


/* ------------------------------------------------------------------------
 * common.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

var Color= new Array();
Color[1] = "ff";
Color[2] = "ee";
Color[3] = "dd";
Color[4] = "cc";
Color[5] = "bb";
Color[6] = "aa";
Color[7] = "99";

function waittofade() {
	if (document.getElementById('fade')) {
    setTimeout("fadeIn(7)", 1000);
	 }
}

function fadeIn(where) {
    if (where >= 1) {
        document.getElementById('fade').style.backgroundColor = "#ffff" + Color[where];
		  if (where > 1) {
			  where -= 1;
			  setTimeout("fadeIn("+where+")", 200);
			} else {
			  where -= 1;
			  setTimeout("fadeIn("+where+")", 200);
			  document.getElementById('fade').style.backgroundColor = "transparent";
			}
    }
}

function validateField(fieldId, alertMessage) {
    if (document.getElementById(fieldId).value == "") {
        alert(alertMessage);
        document.getElementById(fieldId).focus();
        return false;
    } else {
        return true;
    }
}

function popup(url,width,height) {
        window.open(url,'popup','width='+width+',height='+height+',scrollbars=auto,resizable=yes,toolbar=no,directories=no,menubar=no,status=no,left=100,top=100');
        return false;
}

function milestoneResponsibleParty(control, currentUserId) {
  var item = control.options[control.selectedIndex]
  var match = control.name.match(/\[(\d+)\]/)
  var suffix = match ? ("_" + match[1]) : ""
  if(item.value.match(/^c/)) {
    Element.hideIf('reminder' + suffix)
  } else {
    Element.showIf('reminder' + suffix)
  }
  if(item.value.match(new RegExp("^" + currentUserId + "$"))) {
    Element.hideIf('now_and')
  } else {
    Element.showIf('now_and')
  }
}

var ShowHide = Class.create();
ShowHide.prototype = {
  initialize: function(element, callbacks) {
    this.element   = element = $(element);
    this.effect    = element.getAttribute('effect') || 'slide';
    this.duration  = parseFloat(element.getAttribute('duration')) || 0.25;
    this.activeClassName = element.getAttribute('activeclassname') || 'active';
    this.callbacks = callbacks;
    this.active    = Element.visible(element);
    this.element.showHide = this;
  },
  
  togglers: function() {
    return document.getElementsByClassName('show_hide_toggler_' + this.element.id);
  },
  
  toggle: function() {
    if (this.callbacks.beforeToggle) this.callbacks.beforeToggle(this);
    Effect.toggle(this.element, this.effect, {
      duration: this.duration, 
      afterFinish: function(effect) {
        effect.element.firstChild.style.bottom = '0px';
        (this.callbacks.afterToggle || Prototype.K)(this);
      }.bind(this)
    });
    this.active = !this.active;
    this.togglers().concat(this.element).each(this.adjustClassName.bind(this));
  },
  
  show: function() {
    if (this.active) return;
    this.toggle();
  },
  
  hide: function() {
    if (!this.active) return;
    this.toggle();
  },
  
  adjustClassName: function(element) {
    Element[this.active ? 'addClassName' : 'removeClassName'](element, this.activeClassName);
  }
}

/* A pretty little hack to make uploads not hang in Safari. Just call this
 * immediately before the upload is submitted. This does an Ajax call to
 * the server, which returns an empty document with the "Connection: close"
 * header, telling Safari to close the active connection. A hack, but
 * effective. */
function closeKeepAlive() {
  if (/AppleWebKit|MSIE/.test(navigator.userAgent)) {
    new Ajax.Request("/ping/close", { asynchronous:false });
  }
}


var Companies = {
  add: function() {
    new Effect.BlindDown('new_company', { duration: 0.2, afterFinish: function() { $('company_name').focus() } });
  },
  
  justOurCompany: function() {
    $('just_our_company').addClassName('highlight');
    $('another_company_too').removeClassName('highlight');
    $('select_another_company').hide();
  },
  
  anotherCompanyToo: function() {
    $('just_our_company').removeClassName('highlight');
    $('another_company_too').addClassName('highlight');
    $('select_another_company').show();
  },
  
  showCreateNewCompany: function() {
    $('new_company').show();
    $('existing_company').hide();
    $('new_client_name').focus();
  },
  
  showSelectExistingCompany: function() {
    $('new_company').hide();
    $('existing_company').show();
  }
}

/* ------------------------------------------------------------------------
 * contacts.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

contactsManager = {
  onRemoved: function(request, id) {
    new Effect.Fade("company_" + id, {duration: 0.5})
    $('clients_names').innerHTML = request.getResponseHeader("X-Clients-Names")
  },

  onAdd: function(from) {
    this.resetAdd()
    new Effect.BlindDown('AddCompany', { duration: 0.2, afterFinish: function() { $('client_name').focus(); } })
  },

  beginAdd: function() {
    if($('client_id') && !Field.present('client_name'))
      Element.show('add_company_indicator_1')
    else
      Element.show('add_company_indicator_2')
  },

  resetAdd: function() {
    Element.hideIf('add_company_indicator_1', 'add_company_indicator_2')
    Field.clear('client_name')
  },

  updateOptionsList: function(list, value) {
    if(!(list = $(list))) return
    list = list.options
    for(var i = 0; i < list.length; i += 1) {
      if(list[i].value == value) {
        Element.remove(list[i])
        break
      }
    }

    if(list.length == 0) {
      // insert a blank element, because some browsers don't handle the
      // empty case very well
      list[0] = new Option("")
    }
  },

  updateCompanyList: function(request) {
    var new_id = request.getResponseHeader("X-Client-Id")
    var insert_after = request.getResponseHeader("X-Insert-After")
    var content = request.responseText

    // display the correct list of client names in the banner
    if($('clients_names')) {
      var clients_names = request.getResponseHeader("X-Clients-Names")
      $('clients_names').innerHTML = clients_names

      // remove the company from the list of "add client" options
      this.updateOptionsList('client_id', new_id)
    }
    // use the Appear affect to display the company
    var appear = true

    // if the company is already in the list, remove it and reinsert at that
    // location. Otherwise, insert the company in sorted order.
    company = $('company_' + new_id)
    if(company) Element.remove(company)
    
    if(insert_after == "FRONT") {
      new Insertion.Top('clients_list', content)
    } else if(insert_after == "NONE") {
      new Insertion.Bottom('clients_list', content)
    } else {
      new Insertion.After('company_' + insert_after, content)
    }

    // scroll to and display the company
    window.scrollTo(window.pageXOffset ||
                    document.documentElement.scrollLeft ||
                    document.body.scrollLeft || 0,
                    $('company_' + new_id).offsetTop)
    new Effect.Appear('company_' + new_id, {duration: 0.5})
  },

  onAdded: function(request) {
    Element.hide('AddCompany')
    if(request.status == 200) {
      this.updateCompanyList(request, true)
    }
  },

  addPerson: function(from, company_id) {
    this.resetAddPerson(company_id);
    new Effect.BlindDown('AddPerson_' + company_id, {duration: 0.2});
    $('AddPerson_' + company_id).scrollTo();
  },

  resetAddPerson: function(company_id) {
    Element.hide('AddPersonError_' + company_id);
    Field.clear('person_first_name_' + company_id);
    Field.clear('person_last_name_' + company_id);
    Field.clear('person_email_address_' + company_id);
    Field.clear('person_user_name_' + company_id);
    Field.clear('person_password_' + company_id);
    Element.hideIf('add_person_indicator_' + company_id + "_existing",
                   'add_person_indicator_' + company_id + "_new")
  },

  beginPersonAdd: function(company_id, mode) {
    Element.hide('AddPersonError_' + company_id)
    if(mode == "existing") {
      Element.show('add_person_indicator_' + company_id + '_existing')
    } else {
      Element.show('add_person_indicator_' + company_id + '_new')
    }
  },

  onPersonAdded: function(request, company_id) {
    if(request.status == 200) {
      // Used to do this.updateCompanyList(request), but after the perms branch update it didn't fit
      window.location.reload();
    } else {
      $('AddPersonError_' + company_id).innerHTML = "<p>" + request.responseText + "</p>"
      Element.show('AddPersonError_' + company_id)
      Element.hideIf('add_person_indicator_' + company_id + '_existing')
      Element.hideIf('add_person_indicator_' + company_id + '_new')
    }
  },

  onPersonRemoved: function(request) {
    if(request.status == 200) {
      this.updateCompanyList(request)
    }
  },
  
  switchToOpenId: function() {
    this.showOpenId();
    $('open_id_verification_notice').show();
    this.clearAuthenticationFields();
  },

  showOpenId: function() {
    $('open_id').show();
    $('user_name_and_password').hide();    
    $('person_identity_url').focus();
  },
  
  switchToUserNameAndPassword: function() {
    this.showUserNameAndPassword();
    $('open_id_verification_notice').hide();
    this.clearAuthenticationFields();
  },
  
  showUserNameAndPassword: function() {
    $('user_name_and_password').show();
    $('open_id').hide();
    $('person_user_name').focus();
  },
  
  clearAuthenticationFields: function() {
    this.clearIdentityUrl();
    this.clearUserNameAndPassword();
  },

  clearIdentityUrl: function() {
    $('person_identity_url').clear();    
  },
  
  clearUserNameAndPassword: function() {
    $('person_user_name').clear();    
    $('person_password').clear();    
  },

  // 1Password and other managers sometimes fills them out even when hidden, so we need to explicitly clear them
  clearHiddenAuthenticationFields: function() {
    if ($('open_id').style.display == "none") {
      this.clearIdentityUrl();     
    } else {
      this.clearUserNameAndPassword();      
    }
  }
}

ContactsManager = contactsManager; // Hack to please update_page when using page.contacts_manager

/* ------------------------------------------------------------------------
 * custom.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

Element.empty = function(id) {
  return $(id).innerHTML.match(/^\s*$/);
}

Element.showIf = function() {
  for(var i = 0; i < arguments.length; i++ ) {
    var element = $(arguments[i])
    if(element) Element.show(element)
  }
}

Element.hideIf = function() {
  for(var i = 0; i < arguments.length; i++ ) {
    var element = $(arguments[i])
    if(element) Element.hide(element)
  }
}

Element.getY = function(element) {
  if(element.y) return element.y
  if(element.offsetTop || element.offsetParent) {
    var y = element.offsetTop
    while(element = element.offsetParent) y += element.offsetTop
    return y
  }
  return 0
}

Element.resizeTo = function(container, extra) {
  container = $(container)
  var width = container.clientWidth || container.scrollWidth
  width += extra // a hack to account for margins, padding, etc.
  if(width > 0) {
    for(var i = 2; i < arguments.length; i++)
      $(arguments[i]).style.width = width + "px"
  }
}

window.installResizerFor = function() {
  var container_and_elements = arguments
  
  var current_onload = window.onload
  window.onload = function() {
    if(current_onload) current_onload()
    Element.resizeTo.apply(Element, container_and_elements)
  }
  
  var current_onresize = window.onresize
  window.onresize = function() {
    var size = {}
    size.width = window.innerWidth || 
      document.documentElement && document.documentElement.clientWidth ||
      document.body.clientWidth
    size.height = window.innerHeight ||
      document.documentElement && document.documentElement.clientHeight ||
      document.body.clientHeight

    /* keep track of the size from the last resize, because IE likes to call
     * resize over and over even if the window hasn't really resized. */

    if(window.last_size && window.last_size.width == size.width && window.last_size.height == size.height)
      return
    window.last_size = size
    
    if(current_onresize) current_onresize()
    Element.resizeTo.apply(Element, container_and_elements)
  }
}

Element.activate = function(element, activate) {
  element = $(element)

  var inactive_text = element['bc:inactive_text']
  if(!inactive_text) {
    element['bc:inactive_text'] = element.innerHTML
    inactive_text = element.innerHTML
  }

  var active_text = element.getAttribute('bc:active_text') || element.innerHTML
  var active_class = element.getAttribute('bc:active_class') || element.className

  if(!activate) {
    element.innerHTML = inactive_text
    if(active_class) Element.removeClassName(element, active_class)
    element['bc:active'] = false
  } else {
    element.innerHTML = active_text
    if(active_class) Element.addClassName(element, active_class)
    element['bc:active'] = true
  }
}

Effect.Zoom = Class.create()
Effect.Zoom.prototype = {
  initialize: function(from, to, duration, onFinish) {
    this.target = $(to)
    this.initializeZoomer()

    var from = $(from)

    this.onFinish = onFinish

    this.target.style.opacity = 0
    this.target.style.visibility = "hidden"
    Element.show(this.target)

    this.startTop = this.getY(from)
    this.startLeft = this.getX(from)
    var endTop = this.getY(this.target)
    var endLeft = this.getX(this.target)
    this.steps = 30.0 * duration
    this.dx = (endLeft - this.startLeft) / this.steps
    this.dy = (endTop - this.startTop) / this.steps
    this.currentStep = 0
    this.zoomer.style.display = "block"
    this.zoom()
  },

  initializeZoomer: function() {
    this.zoomer = document.createElement("DIV")
    this.zoomer.id = "zoomer"
    this.target.parentNode.appendChild(this.zoomer)
  },

  getX: function(element) {
    if(element.x) return element.x
    if(element.offsetLeft || element.offsetParent) {
      var x = element.offsetLeft
      while(element = element.offsetParent) x += element.offsetLeft
      return x
    }
    return 0
  },

  getY: function(element) {
    return Element.getY(element)
  },

  zoom: function() {
    opacity = 100 - (100.0/this.steps) * this.currentStep
    this.zoomer.style.filter = "alpha(opacity=" + opacity + ")"
    this.zoomer.style.opacity = opacity/100

    var pct = this.currentStep / this.steps
    this.zoomer.style.top = this.startTop + this.dy * this.currentStep + "px"
    this.zoomer.style.left = this.startLeft + this.dx * this.currentStep + "px"
    this.zoomer.style.width = this.target.offsetWidth * pct + "px"
    this.zoomer.style.height = this.target.offsetHeight * pct + "px"

    this.currentStep++
    if(this.currentStep < this.steps)
      setTimeout(this.zoom.bind(this), 20)
    else {
      Element.remove(this.zoomer)
      this.target.style.opacity = 1
      this.target.style.visibility = "visible"
      if(this.onFinish) this.onFinish()
    }
  }
}

Effect.ZoomOut = Class.create()
Effect.ZoomOut.prototype = {
  initialize: function(from, to, time) {
    this.target = $(to)
    this.initializeZoomer()
    var from = $(from)

    this.startTop = this.getY(from)
    this.startLeft = this.getX(from)
    var endTop = this.getY(this.target)
    var endLeft = this.getX(this.target)
    this.startWidth = from.offsetWidth
    this.startHeight = from.offsetHeight
    var endWidth = this.target.offsetHeight
    var endHeight = this.target.offsetHeight
    this.steps = 30.0 * time
    this.dx = (endLeft - this.startLeft) / this.steps
    this.dy = (endTop - this.startTop) / this.steps
    this.dh = (endHeight - this.startHeight) / this.steps
    this.dw = (endWidth - this.startWidth) / this.steps
    this.currentStep = 0
    this.zoomer.style.display = "block"

    new Element.hide(from)
    this.zoom()
  },

  initializeZoomer: function() {
    this.zoomer = document.createElement("DIV")
    this.zoomer.id = "zoomer"
    this.target.parentNode.appendChild(this.zoomer)
  },

  getX: function(element) {
    if(element.x) return element.x
    if(element.offsetLeft || element.offsetParent) {
      var x = element.offsetLeft
      while(element = element.offsetParent) x += element.offsetLeft
      return x
    }
    return 0
  },

  getY: function(element) {
    return Element.getY(element)
  },

  zoom: function() {
    opacity = 100 - (100.0/this.steps) * this.currentStep
    this.zoomer.style.filter = "alpha(opacity=" + opacity + ")"
    this.zoomer.style.opacity = opacity/100

    var pct = this.currentStep / this.steps
    this.zoomer.style.top = this.startTop + this.dy * this.currentStep + "px"
    this.zoomer.style.left = this.startLeft + this.dx * this.currentStep + "px"
    this.zoomer.style.width = this.startWidth + this.dw * this.currentStep + "px"
    this.zoomer.style.height = this.startHeight + this.dh * this.currentStep + "px"

    this.currentStep++
    if(this.currentStep < this.steps)
      setTimeout(this.zoom.bind(this), 20)
    else {
      Element.remove(this.zoomer)
    }
  }
}


/* ------------------------------------------------------------------------
 * date.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

Date.MONTHS   = $w("January February March April May June July August September October November December");
Date.CANONICAL_WEEKDAYS = $w("Sunday Monday Tuesday Wednesday Thursday Friday Saturday");
Date.WEEKDAYS = Date.CANONICAL_WEEKDAYS;
Date.weekStartsOn = 0;

Date.startWeekOn = function(day) {
  if(day == Date.weekStartsOn) return;

  var list = [];
  for(var i = day; i < 7; i++) {
    list.push(Date.CANONICAL_WEEKDAYS[i]);
  }
  for(var i = 0; i < day; i++) {
    list.push(Date.CANONICAL_WEEKDAYS[i]);
  }

  Date.WEEKDAYS = list;
  Date.weekStartsOn = day;
}

Object.extend(Date.prototype, {
  clone: function() {
    return new Date(this.getFullYear(), this.getMonth(), this.getDate(),
      this.getHours(), this.getMinutes(), this.getSeconds(), this.getMilliseconds());
  },
  
  withoutTime: function() {
    return new Date(this.getFullYear(), this.getMonth(), this.getDate());
  },
  
  set: function(values) {
    for (var key in values)
      this["set" + key.charAt(0).toUpperCase() + key.substring(1)](values[key]);
    return this;
  },
  
  next: function(offset) {
    offset = offset === undefined ? 1 : offset;
    return this.clone().set({ date: this.getDate() + offset });
  },

  previous: function(offset) {
    offset = offset === undefined ? 1 : offset;
    return this.next(-offset);
  },
  
  beginningOfWeek: function() {
    var adjustment = this.getDay() - Date.weekStartsOn;
    if(adjustment < 0) adjustment += 7;
    return this.previous(adjustment);
  },
  
  beginningOfMonth: function() {
    return this.clone().set({ date: 1 });
  },
  
  getMonthName: function() {
    return Date.MONTHS[this.getMonth()];
  },
  
  getDayName: function() {
    return Date.WEEKDAYS[this.getDay()];
  },

  isWeekend: function() {
    return (this.getDay() == 0 || this.getDay() == 6);
  },

  equal: function(date) {
    return this.getTime() == date.getTime();
  },
  
  toDateString: function() {
    return [this.getFullYear(), this.getMonth() + 1, 
      this.getDate()].invoke("toPaddedString", 2).join("-");
  }
});

Date.prototype.succ = Date.prototype.next;

var $D = function(date) {
  if (!date) {
    return $D(new Date());
  } else if (date.constructor == Date) {
    return date.withoutTime();
  } else if (date.constructor == Array) {
    return new Date(date[0], date[1] - 1, date[2]);
  } else if (arguments.length == 3) {
    return $D.call(null, $A(arguments));
  } else {
    return $D.call(null, date.split("-"));
  }
};



/* ------------------------------------------------------------------------
 * file_v2.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

function toggleExtended() {
  var extended = $('extended')
  if (extended.style.display == 'none') {
    extended.style.display = 'block'
  } else {
    extended.style.display = 'none'
  }
}

function togglePeople(master, className) {
  var people = document.getElementsByClassName(className);
  if (master.checked) {
    for (i = 0; i < people.length; i++) { people[i].checked = true; }
  } else {
    for (i = 0; i < people.length; i++) { people[i].checked = false; }
  }
}

function toggleMaster(checkbox, master) {
  master = $(master)
  if(!master) return
  if (master.checked && !checkbox.checked) {
    master.checked = false;
  }
}

function toggleDimClientPeople(hide_as_private) {
  hide_as_private.checked ? dimClientPeople() : litClientPeople();
}

function dimClientPeople() {
  var people = document.getElementsByClassName("clientPeople");
  for (i = 0; i < people.length; i++) {
    people[i].checked = false;
    people[i].disabled = true;
  }
}

function litClientPeople() {
  var people = document.getElementsByClassName("clientPeople");
  for (i = 0; i < people.length; i++) { people[i].disabled = false; }
}


/* ------------------------------------------------------------------------
 * hover_observer.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

Element.addMethods({
  upwards: function(element, iterator) {
    while (element = $(element)) {
      if (iterator(element)) return element;
      element = element.parentNode;
    }
  }
});

var HoverObserver = Class.create();

Object.extend(HoverObserver, {
  Options: {
    activationDelay:    0,
    deactivationDelay:  0.5,
    targetClassName:    "hover_target",
    containerClassName: "hover_container",
    activeClassName:    "hover",
    clickToHover:       Prototype.Browser.MobileSafari
  }
});

Object.extend(HoverObserver.prototype, {
  initialize: function(element, options) {
    this.element = $(element);
    this.options = Object.extend(Object.clone(HoverObserver.Options), options || {});
    this.start();
  },
  
  start: function() {
    if (!this.observers) {
      var events = $w(this.options.clickToHover ? "click" : "mouseover mouseout");
      this.observers = events.map(function(name) {
        var handler = this["on" + name.capitalize()].bind(this);
        Event.observe(this.element, name, handler, true);
        return { name: name, handler: handler };
      }.bind(this));
    }
  },
  
  stop: function() {
    if (this.observers) {
      this.observers.each(function(info) {
        Event.stopObserving(this.element, info.name, info.handler, true);
      }.bind(this));
      delete this.observers;
    }
  },
  
  onClick: function(event) {
    var element   = this.activeHoverElement = Element.extend(Event.element(event));
    var container = this.getContainerForElement(element);
    
    if (container) {
      if (this.activeContainer && container == this.activeContainer) 
        return this.deactivateContainer();
      this.activateContainer(container);
    }
  },
  
  onMouseover: function(event) {
    var element   = this.activeHoverElement = Element.extend(Event.element(event));
    var container = this.getContainerForElement(element);
    
    if (container) {
      if (this.activeContainer) {
        this.activateContainer(container);
      } else {
        this.startDelayedActivation(container);
      }
    } else {
      this.startDelayedDeactivation();
    }
  },
  
  onMouseout: function(event) {
    delete this.activeHoverElement;
    this.startDelayedDeactivation();
  },
  
  activateContainer: function(container) {
    this.stopDelayedDeactivation();
    
    if (this.activeContainer) {
      if (this.activeContainer == container) return;
      this.deactivateContainer();
    }
    
    this.activeContainer = container;
    this.activeContainer.addClassName(this.options.activeClassName);
  },
  
  deactivateContainer: function() {
    if (this.activeContainer) {
      this.activeContainer.removeClassName(this.options.activeClassName);
      delete this.activeContainer;
    }
  },
  
  startDelayedActivation: function(container) {
    if (this.options.activationDelay) {
      (function() {
        if (container == this.getContainerForElement(this.activeHoverElement))
          this.activateContainer(container);
        
      }).bind(this).delay(this.options.activationDelay);
    } else {
      this.activateContainer(container);
    }
  },
  
  startDelayedDeactivation: function() {
    if (this.options.deactivationDelay) {
      this.deactivationTimeout = this.deactivationTimeout || function() {
        var container = this.getContainerForElement(this.activeHoverElement);
        if (!container || container != this.activeContainer)
          this.deactivateContainer();
        
      }.bind(this).delay(this.options.deactivationDelay);
    } else {
      this.deactivateContainer();
    }
  },
  
  stopDelayedDeactivation: function() {
    if (this.deactivationTimeout) {
      window.clearTimeout(this.deactivationTimeout);
      delete this.deactivationTimeout;
    }
  },
  
  getContainerForElement: function(element) {
    if (!element) return;
    
    if (element.hasAttribute && !element.hasAttribute("hover_container")) {
      var target    = this.getTargetForElement(element);
      var container = this.getContainerForTarget(target);
      this.cacheContainerFromElementToTarget(container, element, target);
    }
    
    return $(element.readAttribute("hover_container"));
  },
  
  getTargetForElement: function(element) {
    if (!element) return;
    var targetClassName = this.options.targetClassName;
    return element.upwards(function(e) {
      if (e.hasClassName) 
        return e.hasClassName(targetClassName);
    });
  },
  
  getContainerForTarget: function(element) {
    if (!element) return;
    var containerClassName = this.options.containerClassName;
    return element.upwards(function(e) {
      if (e.hasClassName)
        return e.hasClassName(containerClassName);
    });
  },
  
  cacheContainerFromElementToTarget: function(container, element, target) {
    if (container && target) {
      if (!container.id) container.id = "hover_container_" + new Date().getTime();
      element.upwards(function(e) {
        e.writeAttribute("hover_container", container.id);
        if (e == target) return true;
      });
    }
  }
});


/* ------------------------------------------------------------------------
 * ie7_prompt_fix.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

if (Prototype.Browser.IE) {
  window._prompt = window.prompt;
  window.prompt = function(text, value) {
    var self = arguments.callee;

    if (self.useModalDialog) {
      text = (text || "").toString(), value = (value || "").toString();
      return window.showModalDialog("/ie7_prompt_fix.html",
        { title: document.title, text: text.escapeHTML(), value: value.escapeHTML() },
        "dialogHeight:150px;dialogWidth:400px;scroll:no;status:no"
      );

    } else {
      var time = new Date().getTime(), result = window._prompt(text, value);
      if (new Date().getTime() - time < 10) {
        self.useModalDialog = true;
        result = self(text, value);
      }
      return result;
    }
  };
}

/* ------------------------------------------------------------------------
 * layout.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

var Layout = {
  swapWithScreenBody: function(element_to_swap) {
    element_to_swap = $(element_to_swap);
    var screen_body = $('screen_body');
    var from = element_to_swap.visible() ? element_to_swap : screen_body;
    var to   = element_to_swap.visible() ? screen_body : element_to_swap;

    $('swap_from').appendChild(from);
    $('swap_to').appendChild(to);
  
    var field_to_preselect = to.down(".sheet_autofocus");
  
    /*
    if (animate) {
      new Effect.Parallel([
        new Effect.DropOut(from, {sync: true}),
        new Effect.BlindDown(to, {sync: true})
      ], {
        duration: 0.5,
        afterFinish: function() {
          if (field_to_preselect)
            Field.activate.delay(0.25, field_to_preselect);
        }
      });
    } else {
    */
      from.hide();
      to.show();
      if (field_to_preselect)
        Field.activate.delay(0.25, field_to_preselect);
    /*
    }
    */
  }
}



/* ------------------------------------------------------------------------
 * login.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

var Login = {
  loginWithOpenId: function() {
    $$('.open_id_login').invoke('show');
    $$('.user_name_and_password_login').invoke('hide');
    $('identity_url').focus();
    this.clearUserNameAndPassword();
  },
  
  loginWithUserNameAndPassword: function() {
    $$('.user_name_and_password_login').invoke('show');
    $$('.open_id_login').invoke('hide');
    $('username').focus();
    this.clearIdentityUrl();
  },
  
  clearUserNameAndPassword: function() {
    $('username').value = '';
    $('password').value = '';
  },

  clearIdentityUrl: function() {
    $('identity_url').value = '';
  },
  
  // 1Password and other managers sometimes fills them out even when hidden, so we need to explicitly clear them
  clearHiddenFields: function() {
    if ($$('.open_id_login').first().style.display == "none") {
      this.clearIdentityUrl();     
    } else {
      this.clearUserNameAndPassword();      
    }
  }
}

/* ------------------------------------------------------------------------
 * msg.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

var msgs = {
  beforeRemoveAttachment: function(id) {
    Element.show('spin_' + id)
  },

  afterRemoveAttachment: function(id) {
    new Effect.Fade('attachment_' + id,
      {duration: 0.5,
       afterFinish: function() { Element.remove('attachment_' + id) }})
  },

  adjustTextarea: function(textarea, collapsed) {
    var lines = textarea.value.split("\n");
    var count = lines.length;
    lines.each(function(line) { count += parseInt(line.length / 70); });

    var rows = parseInt(collapsed / 20);

    if (count > rows) {
      textarea.style.height = (collapsed * 2) + 'px';
    }

    if (count <= rows) {
      textarea.style.height = collapsed + 'px';
    }
  },

  submitter: {
    prepare: function(form) {
      if(!validateField('post_title', 'Every message needs at least a title')) {
        return false; 
      }
      $('buttons', 'please_wait').each(Element.toggle);
      msgs.submitter.fixAction(form);
      return true;
    },

    prepareComment: function(form) {
      if(!validateField('commentBody', 'Every comment must have a body')) {
        return false; 
      }
      $('buttons', 'please_wait').each(Element.toggle);
      msgs.submitter.fixAction(form);
      return true;
    },

    fixAction: function(form) {
      var needs_upload = false;
      $$('#attachment_fields input').each(function(field) {
        if(field.value.match(/^\s*$/)) {
          var id = field.id.match(/_(\d+)$/)[1];
          msgs.attacher.removeField(id);
        } else {
          needs_upload = true;
        }
      })

      if(!needs_upload) {
        msgs.attacher.hide();
        form.action = form.action.replace(/\/upload\//, "/");
      } else {
        msgs.attacher.working();
      }
    },

    cancelPreview: function() {
      $('Preview').hide();
      $('post_form_container').show();
      $('preview_button').down().disabled = false;
      $('preview_button').show();
      $('edit_button').hide();
      $('post_body').focus();
    }
  },

  attacher: {
    toggle: function() {
      this.visible() ? this.hide(true) : this.show(true)
    },

    show: function(animate) {
      visible = this.visible()

      animate ?
        new Effect.BlindDown('Attachments', {duration: 0.2}) :
        Element.show('Attachments')

      Element.hide('Attachments_link')

      return visible
    },

    hide: function(animate) {
      if(!$('Attachments')) return;

      visible = this.visible();
      
      animate ?
        new Effect.BlindUp('Attachments', {duration: 0.2}) :
        $('Attachments').hide();

      $('Attachments_link').show();

      return visible;
    },

    visible: function() {
      return $('Attachments').style.display != "none";
    },

    working: function() {
      if(!$('Attachments')) return;
      $('add_another_attachment_link').hide();
      $('attaching_files').show();
      $('add_attachment_file_spinner').show();
    },

    removeField: function(id) {
      // remove the form field, so it won't be submitted
      Element.remove("attachment_field_" + id)

      // hide the p tag, so it still counts as a row when determing the next
      // available row number.
      Element.hide("new_attachment_" + id)
    }
  },

  milestoner: {
    toggle: function() {
      this.visible() ? this.hide(true) : this.show(true)
    },

    show: function(animate) {
      visible = this.visible()

      animate ?
        new Effect.BlindDown('RelatedMilestone', {duration: 0.2}) :
        Element.show('RelatedMilestone')

      Element.hide('RelatedMilestone_link')

      return visible
    },

    hide: function(animate) {
      visible = this.visible()
      
      animate ?
        new Effect.BlindUp('RelatedMilestone', {duration: 0.2}) :
        Element.hide('RelatedMilestone')

      Element.show('RelatedMilestone_link')

      return visible
    },

    visible: function() {
      return $('RelatedMilestone').style.display != "none"
    },
    
    associate: function() {
      var list = $('post_milestone_id')
      if(list.selectedIndex == 0) {
        // "none"
        Element.hide('with_milestone')
        Element.show('without_milestone')
      } else {
        // a valid milestone
        Element.hide('without_milestone')
        $('milestone_name').innerHTML = list.options[list.selectedIndex].innerHTML
        Element.show('with_milestone')
        if($('completes_milestone').checked)
          Element.show('completes_milestone_check')
        else
          Element.hide('completes_milestone_check')
      }
      this.hide(true)
    }
  },
  
  notifier: {
    toggle: function() {
      this.visible() ? this.hide() : this.show()
    },

    visible: function() {
      return Element.visible('NotifyBlock')
    },

    show: function() {
      visible = this.visible()

      new Effect.BlindDown('NotifyBlock', {duration: 0.2})
      Element.hide('Notify_link')
      $('notify_everyone').checked = false

      return visible
    },

    hide: function() {
      visible = this.visible()
      
      new Effect.BlindUp('NotifyBlock', {duration: 0.2})
      Element.show('Notify_link')

      return visible
    },
    
    all: function() {
      if($('notify_everyone').checked) this.hide()
    }
  },
  
  formatGuide: {
    toggle: function() {
      this.visible() ? this.hide() : this.show()
    },

    visible: function() {
      return Element.visible('formatting_guide')
    },

    show: function() {
      visible = this.visible()

      new Effect.BlindDown('formatting_guide', {duration: 0.2})
      Element.activate('formatting_guide_link', true)

      return visible
    },

    hide: function() {
      visible = this.visible()
      
      new Effect.BlindUp('formatting_guide', {duration: 0.2})
      Element.activate('formatting_guide_link', false)

      return visible
    }
  }
}


/* ------------------------------------------------------------------------
 * open_bar.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

var OpenBar = {
  selectCurrent: function(application, name) {
    $(document.body).addClassName("with_open_bar");
    
    var app_id  = 'open_bar_app_' + application;
    var link_id = 'open_bar_link_' + application + '_' + name;

    if ($(app_id)) $(app_id).addClassName('on');

    if ($(link_id)) {
      $(link_id).addClassName('current_account');
      if ($(app_id)) $(app_id).innerHTML += ": " + $(link_id).innerHTML; 
      $(link_id).innerHTML = "&bull; " + $(link_id).innerHTML;
    }
  }
};


var Participants = {
  setAll: function(company_id, change) {
    $$('.access_check_box_for_' + company_id).each(function(check_box) { 
      check_box.checked = (change == 'grant' ? 'checked' : '');
    });

    $('spinning_access_for_' + company_id).show();;
    $('access_controls').submit();
  },
    
  toggleRights: function(person_id, checkbox) {
    new_value = checkbox.checked ? "visible" : "hidden";
    $('scheduling_checkbox_' + person_id).checked = checkbox.checked;
    
    this.permissionRadioButtonsFor(person_id).slice(1).each(function(radio_button_name) {
      $(radio_button_name).style.visibility = new_value;
    });
    
    this.updateBackgroundColorsFor(person_id, "scheduling");
    
    this.updateRights(person_id);
  },
  
  updateRights: function(person_id) {
    var spinner = $('spinning_abilities_for_' + person_id);
    spinner.show();
    new Ajax.Request(
      $('access_controls').action, {
        parameters: $('access_controls').serialize(),
        onComplete: function() { spinner.hide(); }
      });
  },
  
  permissionRadioButtonsFor: function(person_id) {
    return ['scheduling_checkbox_', 'communication_', 'prioritizing_', 'scheduling_'].map(function(element) { 
      return element + person_id;
    });
  },
  
  updateAbilitiesFor: function(person_id) {
    this.updateBackgroundColorsFor(person_id);
    this.updateRights(person_id);
  },
  
  updateBackgroundColorsFor: function(person_id) {
    var radio_button_names = this.permissionRadioButtonsFor(person_id);
    var selected_radio_button_name = radio_button_names.slice(1).detect(function(radio_button_name) {
      return $(radio_button_name).getElementsByTagName('input')[0].checked;
    });

            
    var current_radio_button_position = radio_button_names.indexOf(selected_radio_button_name);
    
    var results = radio_button_names.partition(function(radio_button_name) {
      return current_radio_button_position  >= radio_button_names.indexOf(radio_button_name);
    });
    var included = results.first(), excluded = results.last();
    
    included.each(function(radio_button_name) {
      $(radio_button_name).removeClassName('disabled');
    });
    
    excluded.each(function(radio_button_name) {
      $(radio_button_name).addClassName('disabled');
    });
  }
}


/* ------------------------------------------------------------------------
 * contacts.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

People = {
  toggleAccessibleCompanyProjects: function(company_id, checked) {
    if (checked) {
      $$('.accessible_projects_for_' + company_id).each(function(box) { box.checked = 'checked' });
    } else {
      $$('.accessible_projects_for_' + company_id).each(function(box) { box.checked = '' });
    }
  },
  
  checkAllAccessibleProjects: function() {
    $$('.accessible_projects').each(function(box) { box.checked = 'checked' });
  },
  
  uncheckAllAccessibleProjects: function() {
    $$('.accessible_projects').each(function(box) { box.checked = '' });
  },


  switchToOpenId: function() {
    this.showOpenId();
    $('open_id_verification_notice').show();
    this.clearAuthenticationFields();
  },

  showOpenId: function() {
    $('open_id').show();
    $('user_name_and_password').hide();    
    $('person_identity_url').focus();
  },
  
  switchToUserNameAndPassword: function() {
    this.showUserNameAndPassword();
    $('open_id_verification_notice').hide();
    this.clearAuthenticationFields();
  },
  
  showUserNameAndPassword: function() {
    $('user_name_and_password').show();
    $('open_id').hide();
    $('person_user_name').focus();
  },
  
  clearAuthenticationFields: function() {
    this.clearIdentityUrl();
    this.clearUserNameAndPassword();
  },

  clearIdentityUrl: function() {
    $('person_identity_url').clear();    
  },
  
  clearUserNameAndPassword: function() {
    $('person_user_name').clear();    
    $('person_password').clear();    
  },

  // 1Password and other managers sometimes fills them out even when hidden, so we need to explicitly clear them
  clearHiddenAuthenticationFields: function() {
    if ($('open_id').style.display == "none") {
      this.clearIdentityUrl();     
    } else {
      this.clearUserNameAndPassword();      
    }
  }
}

Search = {
  setScope: function(scope, search_terms) {
    $('scope').value = scope;
    $('scope').form.submit();
  }
}



/* ------------------------------------------------------------------------
 * settings.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

var settings = {
  padLogo: {
    before: function() {
      $('pad_logo', 'pad_logo_spinner').each(Element.toggle)
    },

    success: function(request) {
      $('pad_logo', 'pad_logo_spinner').each(Element.toggle)
      if($('pad_logo').checked)
        Element.addClassName("LogoBox", "white")
      else
        Element.removeClassName("LogoBox", "white")
    },

    failure: function(request) {
      $('pad_logo', 'pad_logo_spinner').each(Element.toggle)
      $('pad_logo').checked = !$('pad_logo').checked
      alert("Your request could not be completed. Please try again.")
    }
  }
}

/* ------------------------------------------------------------------------
 * templates.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

function isNotifiable(me,value) {
  return value != me && /^\d+$/.test(value)
}

// either show or hide the "notify" checkbox with the given id.
function setNotifyVisible(list,me,id) {
  text = $( "item_" + id + "_content" )

  if( !list ) {
    list = $( "responsible_parties_" + id )
  }

  selected = list.options[list.selectedIndex].value
  selected_is_valid = isNotifiable( me, selected )

  original_is_valid = false

  // this is a kludge... if the 'text' element is present, then we are on the
  // new/edit page and have to deal with the original values of the various
  // responsible party drop-downs. Otherwise, we don't.
  if( text ) {
    original = list.options[eval("original_"+id)].value
    original_is_valid = isNotifiable( me, original )
  }

  visible = original_is_valid ? ( original != selected && selected_is_valid ) : selected_is_valid
            
  if( selected_is_valid && !visible ) {
    visible = ( text ? ( text.defaultValue != text.value ) : false )
  }

  if( text ) visible = visible && !/^\s*$/.test(text.value)

  span = $( "notify_" + id )
  if( span ) {
    span.style.display = ( visible ? "inline" : "none" )
  }

  delete_span = $( "delete_" + id )
  if( delete_span ) {
    delete_span.style.display = ( visible ? "none" : "inline" )
  }
}

function createResponseReport(response, url, options) {
  options = options || {};

  var popup = document.createElement('div');
  popup.setAttribute('id', 'popup-div');
  popup.style.position = "absolute";
  popup.style.zIndex = 999;
  popup.style.border = "5px solid #f77";
  popup.style.background = "#fee";
  popup.style.left = "10%";
  popup.style.width = "80%";
  popup.style.top = "20px";

  var body = document.createElement('div');
  var controls = document.createElement('div');
  
  popup.appendChild(body);
  popup.appendChild(controls);

  body.style.padding = "10px";
  body.style.textAlign = "left";

  controls.style.borderTop = "1px solid #f77";
  controls.style.padding = "10px";
  controls.style.textAlign = "right";
  controls.style.fontSize = "10px";
  popup.style.background = "#fdd";
  
  controls.innerHTML = "<a href='#' onclick=\"$('popup-div').remove()\">Close</a>";

  body.innerHTML = "<p>Please copy and send the following text to <a href='mailto:support@basecamphq.com'>support@basecamphq.com</a>, to help debug this problem. Please also include information about how to duplicate this error.</p>\n" +
    "<form onsubmit='return false'><textarea name='ignore' style='width: 100%' rows='25'>" +
    "URL: " + url + "\n" +
    "Status: " + response.status + " " + response.statusText + "\n" +
    navigator.userAgent + "\n\n------\n" +
    response.getAllResponseHeaders() + "\n-----\n" +
    response.responseText +
    "</textarea></form>"

  document.body.appendChild(popup);
}

/* =============================== */
/* = General Hover-related tasks = */
/* =============================== */

var Hover = {
  EXIT_DELAY  : 600,
  HOVER_BG_ON : 'url(/images/hover-gradient.gif) left repeat-y',
  HOVER_BG_OFF: 'none',
  
  lastTimer   : null,
  lastCommand : null,
  inhibit     : false,
  
  clearCurrent: function() {
    if(!this.lastTimer) return
    clearTimeout(this.lastTimer)
    eval(this.lastCommand)
    this.lastTimer = this.lastCommand = null
  },
  
  endWith: function(command) {
    if(this.inhibit) return
    this.lastCommand = command
    this.lastTimer = setTimeout(command, this.EXIT_DELAY)
  },
  
  toggle: function(on, container, nubbin) {
    if(this.inhibit) return
    
    if(on) {
      if($(container))
        $(container).style.background = this.HOVER_BG_ON
      Element.showIf(nubbin)
    } else {
      if($(container))
        $(container).style.background = this.HOVER_BG_OFF
      Element.hideIf(nubbin)
    }
  }
}

/* ====================================================== */
/* = Tasks relating to whole lists, or lists in general = */
/* ====================================================== */

var lists = {
  hover: {
    begin: function(id) {
      Hover.clearCurrent()
      Hover.toggle(true, 'list_head_' + id, 'nubbin_list_' + id)
    },
    
    end: function(id, delay) {
      if(delay)
        Hover.endWith('lists.hover.end(' + id + ')')
      else
        Hover.toggle(false, 'list_head_' + id, 'nubbin_list_' + id)
    }
  },
  
  editor: {
    toggle: function(id) {
      var div = $('edit_list_' + id + '_title')
      if(!div.populated) {
        Element.show('list_spinner_' + id)
        new Ajax.Updater({success: div}, todos.list_edit_url,
          {asynchronous:true, parameters:'id=' + id,
           onComplete:function(request) {
             Element.hide('list_spinner_' + id)
             if(request.status == 200) {
               div.populated = true
               lists.editor.toggle(id)
             } else {
               alert(todos.ERROR_MSG)
             }
           }})
      } else {
        lists.hover.end(id, false)
        $(div, 'list_head_' + id, 'list_body_' + id).each(Element.toggle)
        Hover.inhibit = Element.visible(div)
      }
    },
    
    active: function(id) {
      return Element.visible('edit_list_' + id + '_title')
    }
  },
  
  save: {
    before: function(id) {
      Element.show("update_list_" + id)
    },

    failure: function(request, id) {
      Element.hide("update_list_" + id)
      alert(todos.ERROR_MSG)
    }
  },
  
  deleter: {
    before: function(id) {
      Element.show('list_spinner_' + id)
    },

    failure: function(request, id) {
      Element.hide('list_spinner_' + id)
      alert(todos.ERROR_MSG)
    }
  },
  
  reorder: {
    toggle: function() {
      var link = $('lists_reorder_link')
      Element.activate(link, !link['bc:active'])
      if(link['bc:active']) {
        Hover.clearCurrent()
        this.makeDraggableLists()
        Element.hide('new_list_link')
        Element.hide('new_reorder_separator')
      } else {
        Element.show('new_list_link')
        this.setSeparatorVisibility()
      }
      Hover.inhibit = link['bc:active']

      $$('#lists div.list').each(function(list) {
        var id = todos.idOf(list)
        Element.toggle('list_body_' + id)
        if($('drag_list_' + id)) Element.toggle('drag_list_' + id)
        /* hide the privatebug while reordering, so that reordering private lists works in IE */
        if($('privatebug_' + id)) Element.toggle('privatebug_' + id)
        if($('list_desc_' + id)) Element.toggle($('list_desc_' + id))
        if($('list_controls_' + id)) Element.toggle($('list_controls_' + id))
        if(lists.editor.active(id)) lists.editor.toggle(id)
      })
    },
    
    makeDraggableLists: function(id) {
      Sortable.create($('lists'), {tag: 'div'})
      todos.installDragObserver()
    },
    
    setSeparatorVisibility: function() {
      if(todos.uncompletedListsCount() < 2)
        Element.hideIf('new_reorder_separator')
      else
        Element.showIf('new_reorder_separator')
    },

    setLinkVisibility: function() {
      if(todos.uncompletedListsCount() < 2)
        Element.hideIf('lists_reorder_link')
      else
        Element.showIf('lists_reorder_link')
    }
  },
  
  creator: {
    toggle: function() {
      var link = $('new_list_link')
      Element.activate(link, !link['bc:active'])
      if(link['bc:active']) {
        $('new_list_name').value = ""
        $('description').value = ""
        if($('template_id')) $('template_id').selectedIndex = 0
        Element.hideIf('lists_reorder_link', 'new_reorder_separator')
        if(this.templateListVisible()) this.toggleTitleOrTemplate()
        Element.hideIf('blankslate')
        new Effect.BlindDown('new_list', {duration: 0.2,
          afterFinish: function() { Field.focus('new_list_name') }})
      } else {
        new Effect.BlindUp('new_list', {duration: 0.2})
        lists.reorder.setLinkVisibility()
        lists.reorder.setSeparatorVisibility()
        if(todos.uncompletedListsCount() < 1)
          Element.showIf('blankslate')
      }
    },
    
    templateListVisible: function() {
      return $('template_id') && $('template_id').style.display != "none"
    },

    toggleTitleOrTemplate: function() {
      var span = $('title_or_template')

      if(span.style.display == "none") {
        $(span, 'new_list_name', 'new_list_description').each(Element.show)
        $('template_or_title', 'template_id').each(Element.hide)
        $('use_template').value = "0"
      } else {
        $(span, 'new_list_name', 'new_list_description').each(Element.hide)
        $('template_or_title', 'template_id').each(Element.show)
        $('use_template').value = "1"
      }

      $('new_list').style.height = ""
      $('new_list').style.paddingBottom = "10px"
    },

    validate: function() {
      var use_template = $('use_template')
      if(use_template && use_template.value == "1") {
        if($('template_id').selectedIndex == 0) {
          alert('You must select a template first.')
          return false
        }
      } else {
        if(!Field.present('new_list_name')) {
          alert('You must enter a name for the list.')
          return false
        }
      }
      return true
    },

    before: function() {
      Element.show('new_list_spinner')
    },

    failure: function(request, url) {
      Element.hide('new_list_spinner')
      //alert(todos.ERROR_MSG)
      if(!confirm(todos.ERROR_MSG + "\n\nFor more information, click \"Cancel\".")) {
        createResponseReport(request, url);
      }
    }
  }
}

/* ============================================ */
/* = Tasks relating to individual to-do items = */
/* ============================================ */

var todos = {
  ERROR_MSG: "There was an error processing this request.\n" +
             "Please wait a minute and try again.",

  hover: {
    begin: function(id) {
      Hover.clearCurrent()
      Hover.toggle(true, 'show_item_' + id, 'nubbin_item_' + id)
    },
    
    end: function(id, delay) {
      if(delay)
        Hover.endWith('todos.hover.end(' + id + ')')
      else
        Hover.toggle(false, 'show_item_' + id, 'nubbin_item_' + id)
    }
  },
  
  reorder: {
    toggle: function(id) {
      // hide all completed items for the list
      if($('completed_items_' + id)) Element.toggle('completed_items_' + id)

      // activate the link (changes the text and class of the link)
      var link = $('reorder_list_' + id + '_link')
      Element.activate(link, !link['bc:active'])
      if(link['bc:active']) {
        todos.makeDraggable(id)
        lists.hover.end(id, false)
      }
      // don't hover when a reorder request is active
      Hover.inhibit = link['bc:active']

      // toggle the checkbox and the drag icon for each item
      todos.childrenOf('uncompleted_items_list_' + id, 'li', function(item) {
        var id = todos.idOf(item)
        Element.toggle('check_box_for_item_' + id)
        if($('drag_' + id)) Element.toggle('drag_' + id)
      })

      // toggle the "add item" link for the list
      todos.toggleAddItemLink(id)
    }
  },
  
  completer: {
    set: function(id, list) {
      Element.show('ucspin_' + id) // spinner
      new Ajax.Request(todos.item_complete_url,
        {asynchronous:true, evalScripts:true, parameters:'id=' + id,
        onFailure:function(request) { todos.completer.setFailed(request, id) }})
    },

    setFailed: function(request, id) {
      Element.hide('ucspin_' + id)
      $('item_cb_' + id).checked = false
      alert(todos.ERROR_MSG)
    },

    unset: function(id, list) {
      Element.show('cspin_' + id) // spinner
      new Ajax.Request(todos.item_uncomplete_url,
        {asynchronous:true, evalScripts:true, parameters:'id=' + id,
        onFailure:function(request) { todos.completer.unsetFailed(request, id) }})
    },

    unsetFailed: function(request, id) {
      Element.hide('cspin_' + id)
      $('citem_cb_' + id).checked = true
      alert(todos.ERROR_MSG)
    }
  },

  toggleTime: function(id) {
    var time_div = $('time_' + id)
    var content_div = $('ucontent_' + id) || $('ccontent_' + id)
    if(time_div) {
      $(content_div, time_div).each(Element.toggle)
    } else {
      Element.showIf('cspin_' + id, 'ucspin_' + id)
      new Ajax.Updater({success: content_div}, this.item_time_url,
        {asynchronous:true, parameters:'id=' + id,
         insertion:Insertion.After, onComplete:function(request) {
           Element.hideIf('cspin_' + id, 'ucspin_' + id)
           if(request.status == 200) {
             Element.hide(content_div)
           } else {
             alert(todos.ERROR_MSG)
           }
         }})
    }
  },

  toggleAddItemLink: function(id) {
    if($('add_item_' + id)) Element.toggle('add_item_' + id)
  },

  toggleEditItem: function(id) {
    var div = $('edit_item_' + id)
    if(!div.populated) {
      Element.show('ucspin_' + id)
      new Ajax.Updater({success: div}, this.item_edit_url,
        {asynchronous:true, parameters:'id=' + id,
         onComplete:function(request) {
           Element.hide('ucspin_' + id)
           if(request.status == 200) {
             div.populated = true
             todos.toggleEditItem(id)
           } else {
             alert(todos.ERROR_MSG)
           }
         }})
    } else {
      $('show_item_' + id, 'edit_item_' + id).each(Element.toggle)
    }
  },

  toggleAddItem: function(id) {
    $('new_content_' + id).value = ""
    $('add_item_to_list_' + id, 'add_item_' + id + '_link').each(Element.toggle)
    if($('add_item_to_list_' + id).style.display != "none") Field.focus('new_content_' + id)
  },

  onAddItem: function(id) {
    Element.hide('add_item_button_' + id)
    Element.show('add_item_spinner_' + id) // spinner
  },

  onAddedItemFailed: function(request, id) {
    Element.hide('add_item_spinner_' + id)
    Element.show('add_item_button_' + id)
    alert(todos.ERROR_MSG)
  },

  onDeleteItem: function(id, list, want_confirm) {
    var allow = !want_confirm ||
      confirm('Are you sure you want to delete this to-do item?\n\n' +
              'Note: There is no undo.')

    if(allow) {
      Element.showIf('ucspin_' + id, 'cspin_' + id)
      new Ajax.Request(this.item_delete_url, {asynchronous:true,
        evalScripts:true, parameters:'id=' + id,
        onFailure:function(request) {
          Element.hideIf('ucspin_' + id, 'cspin_' + id)
          alert(todos.ERROR_MSG)
        }})
    }
  },

  onEditItem: function(id, list, form) {
    if(Field.present('item_content_' + id)) {
      Element.show('saving_item_' + id)
      new Ajax.Request(this.item_update_url, {asynchronous:true,
         evalScripts:true, parameters:Form.serialize(form) + '&id=' + id,
         onFailure:function(request) {
           Element.hide('saving_item_' + id)
           alert(todos.ERROR_MSG)
         }})
    }
  },

  onItemTimeUpdate: function(id) {
    if(!Field.present('entry_hours_' + id)) {
      alert("You must specify the number of hours spent on this task.")
      Field.focus('entry_hours_' + id)
      return false
    }

    Element.show('time_spinner_' + id)
    return true
  },

  onItemTimeUpdated: function(request, id) {
    var item = $('uncompleted_' + id) || $('completed_item_' + id)
    if(request.status != 200) {
      Element.hide('time_spinner_' + id)
      alert("The time entry could not be recorded.")
    } else {
      item.innerHTML = request.responseText
      new Effect.Highlight(item)
    }
  },

  setListControlVisibility: function(id) {
    if(this.accessibleUncompletedCount(id) < 1)
      Element.hide('list_controls_' + id)
    else
      Element.show('list_controls_' + id)
  },

  setReorderLinkVisibility: function(id) {
    if(this.uncompletedCount(id) < 2)
      Element.hideIf('reorder_list_' + id + '_link')
    else
      Element.showIf('reorder_list_' + id + '_link')
    this.setListControlVisibility(id)
  },

  makeDraggable: function(id) {
    Sortable.create($('uncompleted_items_list_' + id),
      {handle: 'di_' + id})
    this.installDragObserver()
  },

  installDragObserver: function() {
    if(!this.observer_installed) {
      this.observer_installed = true
      Draggables.addObserver({
        onStart: function(name, draggable, event) {},
        onEnd: function(name, draggable, event) {
          var element = draggable.element;
          var siblings = todos.siblingsOf(element);
          var position = siblings.indexOf(element) + 1;

          var parms = "id=" + todos.idOf(element) + "&to=" + position +
            "&only_active=1"

          new Ajax.Request(
            element.tagName == "LI" ?
              todos.item_reorder_url :
              todos.list_reorder_url,
            { parameters: parms, asynchronous: true })
        }
      })
    }
  },

  idOf: function(element) {
    return element ? element.id.split("_")[1] : ""
  },

  siblingsOf: function(element) {
    return $A(element.parentNode.childNodes).select(function(sibling) {
      return sibling.tagName == element.tagName;
    })
  },

  accessibleUncompletedCount: function(id) {
    var count = 0
    this.childrenOf('uncompleted_items_list_' + id, 'li', function(item) {
      var id = todos.idOf(item)
      if($('drag_' + id)) count += 1
    })
    return count
  },

  uncompletedCount: function(id) {
    return this.childrenOf('uncompleted_items_list_' + id, 'li').length
  },

  uncompletedListsCount: function() {
    return this.childrenOf('lists', 'div').length
  },

  reordering: function(id) {
    return $('reorder_list_' + id + '_link').innerHTML != "Reorder"
  },

  childrenOf: function(element, tag, callback) {
    var nodes = $(element).childNodes
    var result
    
    if(!callback) result = new Array()
    tag = tag.toUpperCase()
    for(var i = 0; i < nodes.length; i++)
      if(nodes[i].tagName && nodes[i].tagName == tag) {
        if(callback) callback(nodes[i])
        else result.push(nodes[i])
      }

    if(!callback) return result
  },

  zzz_placeholder: false // so we don't have to remember to add a comma
}


/* ------------------------------------------------------------------------
 * time.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

var timeHandler = {
  HIGHLIGHT_CLASS: "donelink",
  CANCEL_REPORT_CREATION: "Cancel report creation",

  current_id: 0,

  onEdit: function(id) {
    if(this.current_id != 0) this.cancelEdit()
    Element.show('edit_' + id)
    params = "id=" + id
    if(!$('person_column')) params += "&omit_subject=1"
    new Ajax.Request(timeHandler.urls.edit_entry, {
          asynchronous:true,
          onComplete:function(request){timeHandler.onEditing(id, request)},
          parameters:params})
  },

  /* Because IE doesn't let you use Insertion.* on tables, we have to do this
   * bizarre hack, which at least works. */
  tableInsert: function(which, position, text) {
    if(navigator.userAgent.toLowerCase().indexOf("msie") >= 0) {
      var div = document.createElement("div")
      div.innerHTML = "<table>" + text + "</table>"
      var row = div.children[0].rows[0]
      var parent = $(which).parentNode
      var target = $(which)
      if(position == "After") {
        position = "Before"
        target = target.nextSibling
      }
      parent['insert' + position](row, target)
    } else {
      new Insertion[position](which, text)
    }
  },

  onEditing: function(id, request) {
    $('edit_' + id, 'entry_' + id).each(Element.hide)
    timeHandler.current_id = id
    
    this.disableAddRow(true)
    this.tableInsert('entry_' + id, 'Before', request.responseText)
  },

  onSave: function() {
    if(!this.validateOnSave()) return
    Element.show('edit_spinner_' + timeHandler.current_id)

    var form = $('edit_entry_' + timeHandler.current_id);

    var params = Form.serialize(form);
    if(!$('person_column')) params += "&omit_subject=1"

    if(timeHandler.current_id != 0) {
      params = params + "&id=" + timeHandler.current_id
    }

    new Ajax.Request(timeHandler.urls.save_entry, {
          asynchronous:true,
          onComplete:function(request){timeHandler.onSaved(request)},
          parameters:params})
  },

  onSaved: function(request) {
    Element.hide('edit_spinner_' + timeHandler.current_id)

    if(request.status != 200) {
      alert("The time entry could not be saved.")
      return
    }

    var new_id = request.getResponseHeader('X-Entry-Id')

    if(this.current_id == 0) {
      $('entry_adder').reset()
      this.tableInsert("edit_entry_0", 'After', request.responseText)
    } else {
      Element.remove('entry_' + timeHandler.current_id)
      this.tableInsert("edit_entry_" + timeHandler.current_id, 'After', request.responseText)
      Element.remove('edit_entry_' + timeHandler.current_id)
    }

    this.updateTotals(request)

    new Effect.Highlight("entry_" + new_id)

    this.disableAddRow(false)
    this.checkBlankSlate()

    if(this.current_id == 0) {
      $('entry_hours_0').focus();
    }

    this.time_track = null
    this.current_id = 0
  },

  onDelete: function(id) {
    if(confirm('Are you sure you want to delete this time entry?')) {
      Element.show('edit_' + id)
      new Ajax.Request(timeHandler.urls.delete_entry, {
            asynchronous:true, evalScripts:true,
            onComplete:function(request){timeHandler.onDeleted(request, id)},
            parameters:"id=" + id})
    }
  },

  onDeleted: function(request, id) {
    this.updateTotals(request)

    // Effect.Fade does not work with tables, so we can't fade out deleted rows
    if($('edit_entry_' + id)) Element.remove('edit_entry_' + id)
    Element.remove('entry_' + id)
    timeHandler.disableAddRow(false)
    timeHandler.current_id = 0

    this.checkBlankSlate()
  },

  cancelEdit: function() {
    if(this.current_id != 0) Element.remove('edit_entry_' + this.current_id)
    this.disableAddRow(false)
    Element.show('entry_' + this.current_id)
    this.current_id = 0
  },

  disableAddRow: function(disable) {
    if($('edit_entry_0')) {
      selects = $('edit_entry_0').getElementsByTagName("SELECT")
      selects[0].disabled = disable
      selects[1].disabled = disable
      $('entry_person_id_0').disabled = disable
      $('entry_hours_0').disabled = disable
      $('entry_description_0').disabled = disable
      $('entry_submit_0').disabled = disable
    }
  },

  toggleReport: function() {
    var link = $('report_link')
    if(link.className.indexOf(this.HIGHLIGHT_CLASS) < 0) {
      this.original_text = link.innerHTML
      this.original_class = link.className
      link.innerHTML = this.CANCEL_REPORT_CREATION
      link.className += " " + this.HIGHLIGHT_CLASS
      new Effect.BlindDown('new_time_report', {duration: 0.3})
    } else {
      new Effect.BlindUp('new_time_report', {duration: 0.3,
        afterFinish: function() {
          link.innerHTML = timeHandler.original_text
          link.className = timeHandler.original_class
          Element.hide('new_time_report')
        }})
    }
  },

  updateTotals: function(request) {
    var by = parseFloat(request.getResponseHeader('X-Time-Delta'))
    this.updateField('hours_subtotal', by);
    this.updateField('hours_total', by);
  },

  updateField: function(field, by) {
    field = $(field);
    if(field) {
      var amount = parseFloat(field.innerHTML) + by;
      field.innerHTML = amount.toFixed(2);
    }
  },

  checkBlankSlate: function() {
    if(this.isBlank()) {
      $('total', 'csv_export').each(Element.hide)
      if($('report_link_block')) Element.hide('report_link_block')
    } else {
      $('total', 'csv_export').each(Element.show)
      if($('report_link_block')) Element.show('report_link_block')
      if($('blank_slate')) Element.hide('blank_slate')
    }
  },

  isBlank: function() {
    rows = $('entries').getElementsByTagName("TR")
    count = 0
    for(i = 0; i < rows.length; i++) {
      if(rows[i].id.substr(0,6) == "entry_") count++;
    }
    return count == 0
  },

  validateOnSave: function() {
    if(!Field.present("entry_hours_" + this.current_id)) {
      Field.focus('entry_hours_' + this.current_id)
      alert("You must specify the number of hours spent on this task.")
      return false
    }

    return true
  }
}


/* ------------------------------------------------------------------------
 * todos.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

Widget.beforeDragRequestHandlers.push(function(widget, widgetParent) {
  if (widgetParent.id == "widgets") return true;
  
  var listIsTimeTracked = !!widgetParent.up("div.list.list_with_time_tracking");
  var itemIsTimeTracked = !!widget.down("div.item.item_with_time_tracking");
  
  if (listIsTimeTracked != itemIsTimeTracked) {
    if (!listIsTimeTracked) {
      widgetParent.up("div.items_wrapper").addClassName("busy");
    } else {
      widget.addClassName("busy");
    }
  }
  
  return true;
});

Widget.beforeDragRequestHandlers.push(function(widget, widgetParent) {
  if (widgetParent.id == "widgets") return true;
  var listId = widgetParent.up("div.list_wrapper").id, match;
  
  widget.descendants().concat(widget).each(function(element) {
    if (match = (element.id || "").match(/^(.*)list_\d+(.+)/)) {
      element.id = match[1] + listId + match[2];
    }
  });
  
  return true;
});

function setNotifyVisible(notify, value, me, current) {
  var notifiable = value != me && value.match(/^\d+$/) && current != value;
  $(notify)[notifiable ? "show" : "hide"]();
}

Position.includeScrollOffsets = true;


/* ------------------------------------------------------------------------
 * writeboards.js
 * Copyright (c) 2004-2007 37signals, LLC. All rights reserved.
 * ------------------------------------------------------------------------ */

var writeboards = {
  login: function(url, password) {
    $('login_form').action = url
    $('login_password').value = password
    $('login_form').submit()
  },

  checkEmpty: function() {
    var count = $('writeboards').getElementsByTagName('LI').length
    if(count < 1) Element.show('blank_slate')
  },

  showQuotaBlock: function() {
    Element.hide('creation_links')
    Element.showIf('limit_reached')
  },

  hideQuotaBlock: function() {
    Element.show('creation_links')
    Element.hideIf('limit_reached')
  },

  creator: {
    toggle: function() {
      this.visible() ? this.hide(true) : this.show(true)
    },

    show: function(animate) {
      visible = this.visible()

      /* don't animate the showing of this block if the importer is visible */
      if (!writeboards.importer.hide(false)) {
        new Effect.BlindDown('new_writeboard', { 
          duration: 0.2, afterFinish: function() { Field.focus('writeboard_title') } 
        })
      } else {
        Element.show('new_writeboard')
        Field.focus('writeboard_title')
      }

      Element.activate('create_writeboard_link', true)
      Element.hide('blank_slate')
      
      

      return visible
    },

    hide: function(animate) {
      visible = this.visible()

      animate ?
        new Effect.BlindUp('new_writeboard', {duration: 0.2,
          afterFinish: function() { writeboards.checkEmpty() }}) :
        Element.hide('new_writeboard')

      Element.activate('create_writeboard_link', false)

      return visible
    },

    visible: function() {
      return $('new_writeboard').style.display != "none"
    },

    before: function() {
      Element.show('writeboard_new_spinner')
    },

    success: function(request) {
      var url = request.getResponseHeader('X-Login-Url')
      var password = request.getResponseHeader('X-Login-Password')
      writeboards.login(url, password)
    },

    failure: function(request) {
      Element.hide('writeboard_new_spinner')
      if(request.responseText.match(/limit exceeded/)) {
        alert("You must upgrade before adding more writeboards.")
      } else {
        alert("Your request could not be completed. Please try again.")
      }
    }
  },

  importer: {
    toggle: function() {
      this.visible() ? this.hide(true) : this.show(true)
    },

    show: function(animate) {
      visible = this.visible()

      /* don't animate the showing of this block of the creator is visible */
      if (!writeboards.creator.hide(false)) {
        new Effect.BlindDown('importWriteboardBlock', { 
          duration: 0.2, afterFinish: function() { Field.focus('import_url') } 
        })
      } else {
        Element.show('importWriteboardBlock')
        Field.focus('import_url')
      }



      Element.activate('import_writeboard_link', true)
      Element.hide('blank_slate')

      return visible
    },

    hide: function(animate) {
      visible = this.visible()

      animate ?
        new Effect.BlindUp('importWriteboardBlock', {duration: 0.2,
          afterFinish: function() { writeboards.checkEmpty() }}) :
        Element.hide('importWriteboardBlock')
      
      Element.activate('import_writeboard_link', false)

      return visible
    },

    visible: function() {
      return $('importWriteboardBlock').style.display != "none"
    },

    before: function() {
      Element.show('writeboard_import_spinner')
    },

    success: function(request) {
      $('writeboard_import_spinner', 'blank_slate').each(Element.hide)
      this.hide()

      var position = request.getResponseHeader("X-Writeboard-Position")
      var id = request.getResponseHeader("X-Writeboard-Id")
      var quota = request.getResponseHeader("X-Quota-Status")

      if(quota == "stop") writeboards.showQuotaBlock()

      if(position == "bottom")
        new Insertion.Bottom('writeboards', request.responseText)
      else
        new Insertion.Before('writeboard_' + position, request.responseText)

      new Effect.Highlight('writeboard_' + id)
    },

    failure: function(request) {
      Element.hide('writeboard_import_spinner')
      alert("There was an error processing your request. Please try again.")
    },

    notFound: function(request) {
      Element.hide('writeboard_import_spinner')
      alert("The requested Writeboard could not be found.\n\n" +
        "Please double-check the URL and password and try again.")
    }
  },

  remove: {
    toggle: function(id) {
      this.visible(id) ? this.hide(id) : this.show(id)
    },

    show: function(id) {
      $('privacy_' + id, 'show_' + id).each(Element.hide)
      new Effect.BlindDown('remove_' + id, {duration: 0.2})
    },

    hide: function(id) {
      new Effect.BlindUp('remove_' + id, {duration: 0.2,
        afterFinish: function() {
          Element.show('show_' + id) }})
    },

    visible: function(id) {
      return $('remove_' + id).style.display != "none"
    },

    before: function(id) {
      Element.show("remove_spinner_" + id)
    },

    failure: function(request, id) {
      Element.hide("remove_spinner_" + id)
      alert("An error prevented the writeboard being deleted. Please try again.")
    },

    success: function(request, id) {
      new Effect.Fade("writeboard_" + id, {
        afterFinish: function() {
          Element.remove("writeboard_" + id)
          writeboards.hideQuotaBlock()
          writeboards.checkEmpty() }})
    }
  },

  privacy: {
    toggle: function(id) {
      this.visible(id) ? this.hide(id) : this.show(id)
    },

    show: function(id) {
      Element.hideIf('remove_' + id, 'show_' + id)
      new Effect.BlindDown('privacy_' + id, {duration: 0.2})
    },

    hide: function(id) {
      new Effect.BlindUp('privacy_' + id, {duration: 0.2,
        afterFinish: function() {
          Element.show('show_' + id) }})
    },

    visible: function(id) {
      return $('privacy_' + id).style.display != "none"
    },

    before: function(id) {
      Element.show("privacy_spinner_" + id)
      Element.hide("public_" + id)
    },

    failure: function(request, id) {
      Element.hide("privacy_spinner_" + id)
      Element.show("public_" + id)
      $('public_' + id).checked = !$('public_' + id).checked
      alert("An error prevented your request from completing. Please try again.")
    },

    success: function(request, id) {
      $('writeboard_' + id).innerHTML = request.responseText
      new Effect.Highlight('writeboard_' + id)
    }
  }
}
