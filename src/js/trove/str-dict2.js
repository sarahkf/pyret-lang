({
  requires:
    [
      { "import-type": "builtin", name: "valueskeleton" }
    ],
  nativeRequires: ["pyret-base/js/namespace"],
  provides: {
    shorthands: {
      "sdOfA": ["tyapp", ["local", "StringDict"], [["tid", "a"]]],
      "msdOfA": ["tyapp", ["local", "MutableStringDict"], [["tid", "a"]]],

      "Equality": { tag: "name",
                    origin: { "import-type": "uri", uri: "builtin://equality" },
                    name: "EqualityResult" },
      "VS": { tag: "name",
                    origin: { "import-type": "uri", uri: "builtin://valueskeleton" },
                    name: "ValueSkeleton" },
      "SetOfA": ["tyapp", { tag: "name",
               origin: { "import-type": "uri", uri: "builtin://valueskeleton" },
               name: "ValueSkeleton" }, [["tid", "a"]]]
    },
    values: {
      "make-string-dict": ["forall", ["a"], ["arrow", [], "sdOfA"]],
      "make-mutable-string-dict": ["forall", ["a"], ["arrow", [], "msdOfA"]],
      "string-dict": ["forall", ["a"], ["Maker", "Any", "sdOfA"]],
      "mutable-string-dict": ["forall", ["a"], ["Maker", "Any", "msdOfA"]],
      "is-mutable-string-dict": ["arrow", ["Any"], "Boolean"],
      "is-string-dict": ["arrow", ["Any"], "Boolean"],
      "string-dict-of": ["forall", "a", ["arrow", [["List", "String"], ["tid", "a"]], "sdOfA"]]
    },
    aliases: {

    },
    datatypes: {
      "StringDict": ["data", "StringDict", ["a"], [], {
        "get": ["arrow", ["String"], ["Option", ["tid", "a"]]],
        "get-value": ["arrow", ["String"], ["tid", "a"]],
        "set": ["arrow", ["String", ["tid", "a"]], "sdOfA"],
        "merge": ["arrow", ["sdOfA"], "sdOfA"],
        "remove": ["arrow", ["String"], "sdOfA"],
        "keys": ["arrow", [], "SetOfA"],
        "keys-list": ["arrow", [], ["List", ["tid", "a"]]],
        "count": ["arrow", [], "Number"],
        "has-key": ["arrow", ["String"], "Boolean"],
        "_equals": ["arrow", ["sdOfA", ["arrow", ["Any", "Any"], "Equality"]], "Equality"],
        "_output":  ["arrow", [["arrow", ["Any"], "VS"]], "VS"],
        "unfreeze": ["arrow", [], "msdOfA"]
      }],
      "MutableStringDict": ["data", "MutableStringDict", ["a"], [], {
        "get-now": ["arrow", ["String"], ["Option", ["tid", "a"]]],
        "get-value-now": ["arrow", ["String"], ["tid", "a"]],
        "set-now": ["arrow", ["String", ["tid", "a"]], "Nothing"],
        "merge-now": ["arrow", ["msdOfA"], "Nothing"],
        "remove-now": ["arrow", ["String"], "Nothing"],
        "keys-now": ["arrow", [], "SetOfA"],
        "keys-list-now": ["arrow", [], ["List", ["tid", "a"]]],
        "count-now": ["arrow", [], "Number"],
        "has-key-now": ["arrow", ["String"], "Boolean"],
        "_equals": ["arrow", ["sdOfA", ["arrow", ["Any", "Any"], "Equality"]], "Equality"],
        "_output":  ["arrow", [["arrow", ["Any"], "VS"]], "VS"],
        "freeze": ["arrow", [], "sdOfA"],
        "seal": ["arrow", [], "msdOfA"]
      }],
    }
  },
  theModule: function(runtime, namespace, uri, VSlib){
    var O = runtime.makeObject;
    var F = runtime.makeFunction;
    var arity = runtime.checkArity;
    var get = runtime.getField;

    var VS = get(VSlib, "values");

    var brandMutable = runtime.namedBrander("mutable-string-dict", ["string-dict: mutable-string-dict brander"]);
    var brandImmutable = runtime.namedBrander("string-dict", ["string-dict: string-dict brander"]);

    var annMutable = runtime.makeBranderAnn(brandMutable, "MutableStringDict");
    var annImmutable = runtime.makeBranderAnn(brandImmutable, "StringDict");

    var checkMSD = function(v) { runtime._checkAnn(["string-dict"], annMutable, v); };
    var checkISD = function(v) { runtime._checkAnn(["string-dict"], annImmutable, v); };

    function applyBrand(brand, val) {
      return get(brand, "brand").app(val);
    }
    function hasBrand(brand, val) {
      return get(brand, "test").app(val);
    }

    // Prepend a space to avoid conflicting with built-in names
    function internalKey(s) {
      return " " + s;
    }
    // Remove it when internal keys need to be shown to the user
    function userKey(s) {
      return s.slice(1);
    }

    function makeImmutableStringDict(underlyingDict) {

      var getISD = runtime.makeMethod1(function(_, key) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['get'], 2, $a); }
        runtime.checkString(key);
        var mkey = internalKey(key);
        var val = underlyingDict[mkey];
        if (val === undefined) {
          return runtime.ffi.makeNone();
        } else {
          if (!Object.prototype.hasOwnProperty.call(underlyingDict, mkey)) {
            underlyingDict[mkey] = val;
          }
          return runtime.ffi.makeSome(val);
        }
      });

      var getValueISD = runtime.makeMethod1(function(_, key) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['get-value'], 2, $a); }
        runtime.checkString(key);
        var mkey = internalKey(key);
        var val = underlyingDict[mkey];
        if (val === undefined) {
          runtime.ffi.throwMessageException('Key ' + key + ' not found');
        }
        if (!Object.prototype.hasOwnProperty.call(underlyingDict, mkey)) {
          underlyingDict[mkey] = val;
        }
        return val;
      });

      var setISD = runtime.makeMethod2(function(_, key, val) {
        if (arguments.length !== 3) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['set'], 3, $a); }
        runtime.checkString(key);
        runtime.checkPyretVal(val);
        var newObj = Object.create(underlyingDict);
        var mkey = internalKey(key);
        newObj[mkey] = val;
        return makeImmutableStringDict(newObj);
      });

      var mergeISD = runtime.makeMethod1(function(self, other) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(["merge"], 2, $a); }
        checkISD(other);
        var otherKeys = runtime.getField(other, "keys-list").app();
        var otherKeysArr = runtime.ffi.toArray(otherKeys);
        if(otherKeysArr.length === 0) { return self; }
        var newObj = Object.create(underlyingDict);
        for(var i = 0; i < otherKeysArr.length; i++) {
          var mkey = internalKey(otherKeysArr[i])
          newObj[mkey] = runtime.getField(other, "get-value").app(otherKeysArr[i]);
        }
        return makeImmutableStringDict(newObj);
      });

      var removeISD = runtime.makeMethod1(function(_, key) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['remove'], 2, $a); }
        runtime.checkString(key);
        var newObj = Object.create(underlyingDict);
        var mkey = internalKey(key);
        newObj[mkey] = undefined;
        return makeImmutableStringDict(newObj);
      });

      var hasKeyISD = runtime.makeMethod1(function(_, key) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['has-key'], 2, $a); }
        runtime.checkString(key);
        var mkey = internalKey(key);
        var val = underlyingDict[mkey];
        if (val !== undefined) {
          if (!Object.prototype.hasOwnProperty.call(underlyingDict, mkey)) {
            underlyingDict[mkey] = val;
          }
          return runtime.makeBoolean(true);
        } else {
          return runtime.makeBoolean(false);
        }
      });

      function getAllKeys() {
        var keys = [];
        for (var key in underlyingDict) {
          if (underlyingDict[key] !== undefined) {
            keys.push(key);
          }
        }
        return keys;
      }

      var keysISD = runtime.makeMethod0(function(_) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['keys'], 1, $a); }
        var keys = getAllKeys();
        return runtime.ffi.makeTreeSet(keys.map(function(mkey) {
          return runtime.makeString(userKey(mkey));
        }));
      });

      var keysListISD = runtime.makeMethod0(function(_) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['keys-list'], 1, $a); }
        var keys = getAllKeys();
        return runtime.ffi.makeList(keys.map(function(mkey) {
          return runtime.makeString(userKey(mkey));
        }));
      });

      var countISD = runtime.makeMethod0(function(_) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['count'], 1, $a); }
        var num = 0;
        for (var key in underlyingDict) {
          if (underlyingDict[key] !== undefined) {
            num++;
          }
        }
        return runtime.makeNumber(num);
      });

      var outputISD = runtime.makeMethod0(function(_) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['_output'], 1, $a); }
        var elts = [];
        var keys = getAllKeys();
        var vsValue = get(VS, "vs-value");
        for (var i = 0; i < keys.length; i++) {
          elts.push(vsValue.app(userKey(keys[i])));
          elts.push(vsValue.app(underlyingDict[keys[i]]));
        }
        return get(VS, "vs-collection").app(
          runtime.makeString("string-dict"),
          runtime.ffi.makeList(elts));
      });

      var equalsISD = runtime.makeMethod2(function(self, other, recursiveEquality) {
        if (arguments.length !== 3) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['equals'], 3, $a); }
        if (!hasBrand(brandImmutable, other)) {
          return runtime.ffi.notEqual.app('', self, other);
        } else {
          var keys = getAllKeys();
          var otherKeysLength = get(other, 'count').app();
          function equalsHelp() {
            if (keys.length === 0) {
              return runtime.ffi.equal;
            } else {
              var thisKey = keys.pop();
              if (!get(other, 'has-key').app(userKey(thisKey))) {
                return runtime.ffi.notEqual.app('', self, other);
              } else {
                return runtime.safeCall(function() {
                  return recursiveEquality.app(underlyingDict[thisKey],
                      get(other, 'get-value').app(userKey(thisKey)));
                },
                function (result) {
                  if (runtime.ffi.isNotEqual(result)) {
                    return result;
                  } else {
                    return equalsHelp();
                  }
                });
              }
            }
          }
          if (keys.length !== otherKeysLength) {
            return runtime.ffi.notEqual.app('', self, other);
          } else {
            return equalsHelp();
          }
        }
      });

      var unfreezeISD = runtime.makeMethod0(function(_) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['unfreeze'], 1, $a); }
        var dict = Object.create(null);
        for (var mkey in underlyingDict) {
          var val = underlyingDict[mkey];
          if(val !== undefined) {
            dict[mkey] = underlyingDict[mkey];
          }
        }
        return makeMutableStringDict(dict);
      });

      obj = O({
        get: getISD,
        'get-value': getValueISD,
        set: setISD,
        merge: mergeISD,
        remove: removeISD,
        keys: keysISD,
        "keys-list": keysListISD,
        count: countISD,
        'has-key': hasKeyISD,
        _equals: equalsISD,
        _output: outputISD,
        unfreeze: unfreezeISD
      });

      return applyBrand(brandImmutable, obj);

    }

    function makeMutableStringDict(underlyingDict, sealed) {
      // NOTE(joe): getMSD/setMSD etc are internal to
      // makeMutableStringDict because they need to close over underlyingDict

      var getMSD = runtime.makeMethod1(function(_, key) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['get-now'], 2, $a); }
        runtime.checkString(key);
        var mkey = internalKey(key);
        var val = underlyingDict[mkey];
        if (val === undefined) {
          return runtime.ffi.makeNone();
        } else {
          return runtime.ffi.makeSome(val);
        }
      });

      var getValueMSD = runtime.makeMethod1(function(_, key) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(["get-value-now"], 2, $a); }
        runtime.checkString(key);
        var mkey = internalKey(key);
        var val = underlyingDict[mkey];
        if (val === undefined) {
          runtime.ffi.throwMessageException("Key " + key + " not found");
        }
        return val;
      });

      var setMSD = runtime.makeMethod2(function(self, key, val) {
        if (arguments.length !== 3) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(["set-now"], 3, $a); }
        if (sealed) {
          runtime.ffi.throwMessageException("Cannot modify sealed string dict");
        }
        runtime.checkString(key);
        runtime.checkPyretVal(val);
        underlyingDict[internalKey(key)] = val;
        return runtime.nothing;
      });

      var mergeMSD = runtime.makeMethod1(function(self, other) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(["merge-now"], 2, $a); }
        checkMSD(other);
        var otherKeys = runtime.getField(other, "keys-list-now").app();
        var otherKeysArr = runtime.ffi.toArray(otherKeys);
        for(var i = 0; i < otherKeysArr.length; i++) {
          var key = otherKeysArr[i];
          var val = runtime.getField(other, "get-value-now").app(key);
          runtime.getField(self, "set-now").app(key, val);
        }
        return runtime.nothing;
      });

      var removeMSD = runtime.makeMethod1(function(self, key) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(["remove-now"], 2, $a); }
        if (sealed) {
          runtime.ffi.throwMessageException("Cannot modify sealed string dict");
        }
        runtime.checkString(key);
        delete underlyingDict[internalKey(key)];
        return runtime.nothing;
      });

      var hasKeyMSD = runtime.makeMethod1(function(_, key) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(["has-key-now"], 2, $a); }
        runtime.checkString(key);
        var mkey = internalKey(key);
        if (mkey in underlyingDict) {
          return runtime.makeBoolean(true);
        } else {
          return runtime.makeBoolean(false);
        }
      });

      var keysMSD = runtime.makeMethod0(function(self) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(["keys-now"], 1, $a); }
        var keys = Object.keys(underlyingDict);
        return runtime.ffi.makeTreeSet(keys.map(function(mkey) {
          return runtime.makeString(userKey(mkey));
        }));
      });

      var keysListMSD = runtime.makeMethod0(function(_) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['keys-list-now'], 1, $a); }
        var keys = Object.keys(underlyingDict);
        return runtime.ffi.makeList(keys.map(function(mkey) {
          return runtime.makeString(userKey(mkey));
        }));
      });

      var countMSD = runtime.makeMethod0(function(_) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(["count-now"], 1, $a); }
        return runtime.makeNumber(Object.keys(underlyingDict).length);
      });

      var toreprMSD = runtime.makeMethod1(function(self, recursiveToRepr) {
        if (arguments.length !== 2) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(["torepr"], 2, $a); }
        var keys = Object.keys(underlyingDict);
        var elts = [];
        function combine(elts) {
          //return "[string-dict: " + elts.join(", ") + "]";
          return "[mutable-string-dict: " + elts.join(", ") + "]";
        }
        function toreprElts() {
          if (keys.length === 0) { return combine(elts); }
          else {
            var thisKey = keys.pop();
            // The function recursiveToRepr is a callback for rendering
            // sub-elements of collections.  If we call it on anything other
            // than flat primitives, we need to use the following safeCall
            // calling convention, which makes this work with the stack
            // compilation strategy for Pyret.
            return runtime.safeCall(function() {
              return recursiveToRepr.app(underlyingDict[thisKey]);
            },
            function(result /* stringification of element */) {
              elts.push(recursiveToRepr.app(userKey(thisKey)));
              elts.push(result);
              return toreprElts();
            });
          }
        }
        return toreprElts();
      });
      var outputMSD = runtime.makeMethod0(function(_) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['_output'], 1, $a); }
        var elts = [];
        var keys = Object.keys(underlyingDict);
        var vsValue = get(VS, "vs-value");
        for (var i = 0; i < keys.length; i++) {
          elts.push(vsValue.app(userKey(keys[i])));
          elts.push(vsValue.app(underlyingDict[keys[i]]));
        }
        return get(VS, "vs-collection").app(
          runtime.makeString("mutable-string-dict"),
          runtime.ffi.makeList(elts));
      });

      var equalsMSD = runtime.makeMethod2(function(self, other, recursiveEquality) {
        if (arguments.length !== 3) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(["equals"], 3, $a); }
        if (!hasBrand(brandMutable, other)) {
          return runtime.ffi.notEqual.app("", self, other);
        } else {
          var keys = Object.keys(underlyingDict);
          var otherKeysLength = get(other, "count-now").app();
          function eqElts() {
            if (keys.length === 0) {
              return runtime.ffi.equal;
            } else {
              var thisKey = keys.pop();
              if (!get(other, 'has-key-now').app(userKey(thisKey))) {
                return runtime.ffi.notEqual.app('', self, other);
              } else {
                return runtime.safeCall(function() {
                  return recursiveEquality.app(underlyingDict[thisKey],
                      get(other, 'get-value-now').app(userKey(thisKey)));
                },
                function (result) {
                  if (runtime.ffi.isNotEqual(result)) {
                    return result;
                  } else {
                    return eqElts();
                  }
                });
              }
            }
          }
          if (keys.length !== otherKeysLength) {
            return runtime.ffi.notEqual.app("", self, other);
          } else {
            return eqElts();
          }
        }
      });

      var freezeMSD = runtime.makeMethod0(function(_) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['freeze'], 1, $a); }
        var dict = Object.create(null);
        for (var mkey in underlyingDict) {
          dict[mkey] = underlyingDict[mkey];
        }
        return makeImmutableStringDict(dict);
      });

      var sealMSD = runtime.makeMethod0(function(_) {
        if (arguments.length !== 1) { var $a=new Array(arguments.length); for (var $i=0;$i<arguments.length;$i++) { $a[$i]=arguments[$i]; } throw runtime.ffi.throwArityErrorC(['seal'], 1, $a); }
        return makeMutableStringDict(underlyingDict, true);
      });

      var NYI = runtime.makeMethodFromFun(function(self) {
        runtime.ffi.throwMessageException("Not yet implemented");
      });

      obj = O({
        'get-now': getMSD,
        'get-value-now': getValueMSD,
        'set-now': setMSD,
        'merge-now': mergeMSD,
        'remove-now': removeMSD,
        'keys-now': keysMSD,
        'keys-list-now': keysListMSD,
        'count-now': countMSD,
        'has-key-now': hasKeyMSD,
        _equals: equalsMSD,
        _output: outputMSD,
        freeze: freezeMSD,
        seal: sealMSD
      });

      return applyBrand(brandMutable, obj);
    }

    function internal_isMSD(obj) {
      return hasBrand(brandMutable, obj);
    }

    var jsCheckMSD =
        runtime.makeCheckType(internal_isMSD, "MutableStringDict")

    function isMutableStringDict(obj) {
      arity(1, arguments, "is-mutable-string-dict")
      return runtime.makeBoolean(internal_isMSD(obj))
    }

    function createMutableStringDict() {
      arity(0, arguments, "make-mutable-string-dict");
      var dict = Object.create(null);
      return makeMutableStringDict(dict);
    }

    function createMutableStringDictFromArray(array) {
      arity(1, arguments, "mutable-string-dict");
      runtime.checkArray(array);
      var dict = Object.create(null);
      var len = array.length;
      if(len % 2 !== 0) {
        runtime.ffi.throwMessageException("Expected an even number of arguments to constructor for mutable dictionaries, got array of length " + len);
      }
      for(var i = 0; i < len; i += 2) {
        var key = array[i];
        var val = array[i + 1];
        runtime.checkString(key);
        dict[internalKey(key)] = val;
      }
      return makeMutableStringDict(dict);
    }

    function internal_isISD(obj) {
      return hasBrand(brandImmutable, obj);
    }

    var jsCheckISD =
        runtime.makeCheckType(internal_isISD, "StringDict")

    function isImmutableStringDict(obj) {
      arity(1, arguments, "is-immutable-string-dict")
      return runtime.makeBoolean(internal_isISD(obj))
    }

    function createImmutableStringDict() {
      arity(0, arguments, "make-string-dict");
      var dict = Object.create(null);
      return makeImmutableStringDict(dict);
    }

    function createImmutableStringDictFromArray(array) {
      arity(1, arguments, "string-dict");
      runtime.checkArray(array);
      var dict = Object.create(null);
      var len = array.length;
      if(len % 2 !== 0) {
        runtime.ffi.throwMessageException("Expected an even number of arguments to constructor for immutable dictionaries, got array of length " + len);
      }
      for(var i = 0; i < len; i += 2) {
        var key = array[i];
        var val = array[i + 1];
        runtime.checkString(key);
        var ikey = internalKey(key);
        if (dict[ikey] !== undefined) {
          runtime.ffi.throwMessageException("Creating immutable string dict with duplicate key " + key);
        }
        dict[internalKey(key)] = val;
      }
      return makeImmutableStringDict(dict);
    }

    function createConstImmutableStringDict(names, val) {
      arity(2, arguments, "string-dict-of");
      runtime.checkList(names);
      var arr = runtime.ffi.toArray(names);
      var dict = Object.create(null);
      arr.forEach(function(k) {
        dict[internalKey(k)] = val;
      });
      return makeImmutableStringDict(dict);
    }

    var NYIF = F(function() {
      runtime.ffi.throwMessageException("Not yet implemented");
    });

    function createMutableStringDict0() {
      arity(0, arguments, "mutable-string-dict0");
      var dict = Object.create(null);
      return makeMutableStringDict(dict);
    }
    function createMutableStringDict1(arg) {
      arity(1, arguments, "mutable-string-dict1");
      runtime.ffi.throwMessageException("Expected an even number of arguments to constructor for mutable dictionaries, got " + arguments.length);
    }
    function createMutableStringDict2(a, b) {
      arity(2, arguments, "mutable-string-dict2");
      var dict = Object.create(null);
      runtime.checkString(a);
      dict[internalKey(a)] = b;
      return makeMutableStringDict(dict);
    }
    function createMutableStringDict3(a, b, c) {
      arity(3, arguments, "mutable-string-dict3");
      runtime.ffi.throwMessageException("Expected an even number of arguments to constructor for mutable dictionaries, got " + arguments.length);
    }
    function createMutableStringDict4(a, b, c, d) {
      arity(4, arguments, "mutable-string-dict4");
      var dict = Object.create(null);
      runtime.checkString(a);
      runtime.checkString(c);
      dict[internalKey(a)] = b;
      dict[internalKey(c)] = d;
      return makeMutableStringDict(dict);
    }
    function createMutableStringDict5(a, b, c, d, e) {
      arity(5, arguments, "mutable-string-dict5");
      runtime.ffi.throwMessageException("Expected an even number of arguments to constructor for mutable dictionaries, got " + arguments.length);
    }

    function createImmutableStringDict0() {
      arity(0, arguments, "string-dict0");
      var dict = Object.create(null);
      return makeImmutableStringDict(dict);
    }
    function createImmutableStringDict1(arg) {
      arity(1, arguments, "string-dict1");
      runtime.ffi.throwMessageException("Expected an even number of arguments to constructor for immutable dictionaries, got " + arguments.length);
    }
    function createImmutableStringDict2(a, b) {
      arity(2, arguments, "string-dict2");
      var dict = Object.create(null);
      runtime.checkString(a);
      dict[internalKey(a)] = b;
      return makeImmutableStringDict(dict);
    }
    function createImmutableStringDict3(a, b, c) {
      arity(3, arguments, "string-dict3");
      runtime.ffi.throwMessageException("Expected an even number of arguments to constructor for immutable dictionaries, got " + arguments.length);
    }
    function createImmutableStringDict4(a, b, c, d) {
      arity(4, arguments, "string-dict4");
      var dict = Object.create(null);
      runtime.checkString(a);
      runtime.checkString(c);
      if (a === c) {
        runtime.ffi.throwMessageException("Creating immutable string dict with duplicate key " + a)
      }
      dict[internalKey(a)] = b;
      dict[internalKey(c)] = d;
      return makeImmutableStringDict(dict);
    }
    function createImmutableStringDict5(a, b, c, d, e) {
      arity(5, arguments, "string-dict5");
      runtime.ffi.throwMessageException("Expected an even number of arguments to constructor for immutable dictionaries, got " + arguments.length);
    }

    return O({
      "provide-plus-types": O({
        types: {
          MutableStringDict: annMutable,
          StringDict: annImmutable
        },
        values: O({
          "make-mutable-string-dict": F(createMutableStringDict),
          "mutable-string-dict": O({
            make: F(createMutableStringDictFromArray),
            make0: F(createMutableStringDict0),
            make1: F(createMutableStringDict1),
            make2: F(createMutableStringDict2),
            make3: F(createMutableStringDict3),
            make4: F(createMutableStringDict4),
            make5: F(createMutableStringDict5)
          }),
          "is-mutable-string-dict": F(isMutableStringDict),
          "make-string-dict": F(createImmutableStringDict),
          "string-dict": O({
            make: F(createImmutableStringDictFromArray),
            make0: F(createImmutableStringDict0),
            make1: F(createImmutableStringDict1),
            make2: F(createImmutableStringDict2),
            make3: F(createImmutableStringDict3),
            make4: F(createImmutableStringDict4),
            make5: F(createImmutableStringDict5)
          }),
          "string-dict-of": F(createConstImmutableStringDict),
          "is-string-dict": F(isImmutableStringDict)
        }),
        internal: {
          checkISD: jsCheckISD,
          checkMSD: jsCheckMSD
        }
      }),
      "answer": runtime.nothing
    });
  }
})
