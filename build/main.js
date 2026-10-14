(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.G.B === region.K.B)
	{
		return 'on line ' + region.G.B;
	}
	return 'on lines ' + region.G.B + ' through ' + region.K.B;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**_UNUSED/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.Q,
		impl.S,
		impl.R,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}
var $elm$core$Basics$EQ = 1;
var $elm$core$Basics$LT = 0;
var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$GT = 2;
var $elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Basics$False = 1;
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Maybe$Nothing = {$: 1};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 1) {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.b) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.c),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.c);
		} else {
			var treeLen = builder.b * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.d) : builder.d;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.b);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.c) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.c);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{d: nodeList, b: (len / $elm$core$Array$branchFactor) | 0, c: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = 0;
var $elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === -2) {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$json$Json$Encode$dict = F3(
	function (toKey, toValue, dictionary) {
		return _Json_wrap(
			A3(
				$elm$core$Dict$foldl,
				F3(
					function (key, value, obj) {
						return A3(
							_Json_addField,
							toKey(key),
							toValue(value),
							obj);
					}),
				_Json_emptyObject(0),
				dictionary));
	});
var $elm$json$Json$Encode$bool = _Json_wrap;
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(0),
				entries));
	});
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Jorn$Internal$Vdom$encodeOptions = function (options) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'preventDefault',
				$elm$json$Json$Encode$bool(options.F)),
				_Utils_Tuple2(
				'stopPropagation',
				$elm$json$Json$Encode$bool(options.H)),
				_Utils_Tuple2(
				'include',
				A2($elm$json$Json$Encode$list, $elm$json$Json$Encode$string, options.E))
			]));
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $author$project$Jorn$Internal$Vdom$encodeNode = function (node) {
	if (node.$ === 1) {
		var content = node.a;
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'text',
					$elm$json$Json$Encode$string(content))
				]));
	} else {
		var r = node.a;
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'tag',
					$elm$json$Json$Encode$string(r.O)),
					_Utils_Tuple2(
					'namespace',
					$elm$json$Json$Encode$string(r.M)),
					_Utils_Tuple2(
					'attrs',
					A3($elm$json$Json$Encode$dict, $elm$core$Basics$identity, $elm$json$Json$Encode$string, r.I)),
					_Utils_Tuple2(
					'props',
					A3($elm$json$Json$Encode$dict, $elm$core$Basics$identity, $elm$core$Basics$identity, r.N)),
					_Utils_Tuple2(
					'events',
					A3($elm$json$Json$Encode$dict, $elm$core$Basics$identity, $author$project$Jorn$Internal$Vdom$encodeOptions, r.P)),
					_Utils_Tuple2(
					'children',
					A2($elm$json$Json$Encode$list, $author$project$Jorn$Internal$Vdom$encodeNode, r.J))
				]));
	}
};
var $author$project$Jorn$Internal$Vdom$NodeElement = function (a) {
	return {$: 0, a: a};
};
var $author$project$Jorn$Internal$Vdom$NodeText = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Dict$Black = 1;
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var $elm$core$Dict$Red = 0;
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1) {
				case 0:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $author$project$Jorn$Internal$Vdom$mergeClass = F2(
	function (value, existing) {
		if (existing.$ === 1) {
			return $elm$core$Maybe$Just(value);
		} else {
			var previous = existing.a;
			return $elm$core$String$isEmpty(value) ? $elm$core$Maybe$Just(previous) : ($elm$core$String$isEmpty(previous) ? $elm$core$Maybe$Just(value) : $elm$core$Maybe$Just(previous + (' ' + value)));
		}
	});
var $elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var $elm$core$List$member = F2(
	function (x, xs) {
		return A2(
			$elm$core$List$any,
			function (a) {
				return _Utils_eq(a, x);
			},
			xs);
	});
var $author$project$Jorn$Internal$Vdom$addPaths = F2(
	function (paths, existing) {
		return A3(
			$elm$core$List$foldl,
			F2(
				function (path, acc) {
					return A2($elm$core$List$member, path, acc) ? acc : _Utils_ap(
						acc,
						_List_fromArray(
							[path]));
				}),
			existing,
			paths);
	});
var $author$project$Jorn$Internal$Vdom$combineOptions = F2(
	function (added, options) {
		return {
			E: A2($author$project$Jorn$Internal$Vdom$addPaths, added.E, options.E),
			F: added.F || options.F,
			H: added.H || options.H
		};
	});
var $author$project$Jorn$Internal$Vdom$defaultOptions = {E: _List_Nil, F: false, H: false};
var $author$project$Jorn$Internal$Vdom$splitOptions = function (attribute) {
	if (attribute.$ === 3) {
		var added = attribute.a;
		var wrapped = attribute.b;
		var _v1 = $author$project$Jorn$Internal$Vdom$splitOptions(wrapped);
		var nested = _v1.a;
		var bare = _v1.b;
		return _Utils_Tuple2(
			A2($author$project$Jorn$Internal$Vdom$combineOptions, added, nested),
			bare);
	} else {
		return _Utils_Tuple2($author$project$Jorn$Internal$Vdom$defaultOptions, attribute);
	}
};
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === -1) && (dict.d.$ === -1)) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.e.d.$ === -1) && (!dict.e.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.d.d.$ === -1) && (!dict.d.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === -1) && (!left.a)) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === -1) && (right.a === 1)) {
					if (right.d.$ === -1) {
						if (right.d.a === 1) {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === -1) && (dict.d.$ === -1)) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor === 1) {
			if ((lLeft.$ === -1) && (!lLeft.a)) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === -1) {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === -2) {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === -1) && (left.a === 1)) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === -1) && (!lLeft.a)) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === -1) {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === -1) {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === -1) {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _v0 = alter(
			A2($elm$core$Dict$get, targetKey, dictionary));
		if (!_v0.$) {
			var value = _v0.a;
			return A3($elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2($elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var $author$project$Jorn$Internal$Vdom$addFact = F2(
	function (attribute, acc) {
		var _v0 = $author$project$Jorn$Internal$Vdom$splitOptions(attribute);
		var options = _v0.a;
		var bare = _v0.b;
		switch (bare.$) {
			case 0:
				if (bare.a === 'class') {
					var value = bare.b;
					return _Utils_update(
						acc,
						{
							I: A3(
								$elm$core$Dict$update,
								'class',
								$author$project$Jorn$Internal$Vdom$mergeClass(value),
								acc.I)
						});
				} else {
					var name = bare.a;
					var value = bare.b;
					return _Utils_update(
						acc,
						{
							I: A3($elm$core$Dict$insert, name, value, acc.I)
						});
				}
			case 1:
				var name = bare.a;
				var value = bare.b;
				return _Utils_update(
					acc,
					{
						N: A3($elm$core$Dict$insert, name, value, acc.N)
					});
			case 2:
				var name = bare.a;
				var decoder = bare.b;
				return _Utils_update(
					acc,
					{
						P: A3(
							$elm$core$Dict$insert,
							name,
							_Utils_Tuple2(options, decoder),
							acc.P)
					});
			default:
				return acc;
		}
	});
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $author$project$Jorn$Internal$Vdom$facts = function (attributes) {
	return A3(
		$elm$core$List$foldl,
		$author$project$Jorn$Internal$Vdom$addFact,
		{I: $elm$core$Dict$empty, P: $elm$core$Dict$empty, N: $elm$core$Dict$empty},
		attributes);
};
var $elm$core$Dict$map = F2(
	function (func, dict) {
		if (dict.$ === -2) {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				A2(func, key, value),
				A2($elm$core$Dict$map, func, left),
				A2($elm$core$Dict$map, func, right));
		}
	});
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $author$project$Jorn$Internal$Vdom$toNode = function (html) {
	if (html.$ === 1) {
		var content = html.a;
		return $author$project$Jorn$Internal$Vdom$NodeText(content);
	} else {
		var namespace = html.a;
		var tag = html.b;
		var attributes = html.c;
		var children = html.d;
		var f = $author$project$Jorn$Internal$Vdom$facts(attributes);
		return $author$project$Jorn$Internal$Vdom$NodeElement(
			{
				I: f.I,
				J: A2($elm$core$List$map, $author$project$Jorn$Internal$Vdom$toNode, children),
				P: A2(
					$elm$core$Dict$map,
					F2(
						function (_v1, _v2) {
							var options = _v2.a;
							return options;
						}),
					f.P),
				M: namespace,
				N: f.N,
				O: tag
			});
	}
};
var $author$project$Jorn$Patch$encodeHtml = function (element) {
	return $author$project$Jorn$Internal$Vdom$encodeNode(
		$author$project$Jorn$Internal$Vdom$toNode(element));
};
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $author$project$Main$fromClient = _Platform_incomingPort('fromClient', $elm$json$Json$Decode$value);
var $author$project$Main$Everything = {$: 0};
var $author$project$Main$Night = 1;
var $author$project$Main$Paper = 0;
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $elm$json$Json$Decode$field = _Json_decodeField;
var $author$project$Main$init = function (flags) {
	return {
		r: $author$project$Main$Everything,
		A: function () {
			var _v0 = A2(
				$elm$json$Json$Decode$decodeValue,
				A2($elm$json$Json$Decode$field, 'dark', $elm$json$Json$Decode$bool),
				flags);
			if ((!_v0.$) && _v0.a) {
				return 1;
			} else {
				return 0;
			}
		}()
	};
};
var $elm$core$Result$andThen = F2(
	function (callback, result) {
		if (!result.$) {
			var value = result.a;
			return callback(value);
		} else {
			var msg = result.a;
			return $elm$core$Result$Err(msg);
		}
	});
var $author$project$Jorn$Internal$Event$Incoming = F3(
	function (path, name, event) {
		return {L: event, C: name, D: path};
	});
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$json$Json$Decode$map3 = _Json_map3;
var $elm$json$Json$Decode$string = _Json_decodeString;
var $author$project$Jorn$Internal$Event$decoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Jorn$Internal$Event$Incoming,
	A2(
		$elm$json$Json$Decode$field,
		'path',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$int)),
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'event', $elm$json$Json$Decode$value));
var $author$project$Jorn$Internal$Patch$Append = F2(
	function (a, b) {
		return {$: 8, a: a, b: b};
	});
var $author$project$Jorn$Internal$Patch$Replace = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$Jorn$Internal$Patch$SetText = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $author$project$Jorn$Internal$Patch$Truncate = F2(
	function (a, b) {
		return {$: 9, a: a, b: b};
	});
var $author$project$Jorn$Internal$Patch$RemoveAttribute = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $author$project$Jorn$Internal$Patch$RemoveEvent = F2(
	function (a, b) {
		return {$: 7, a: a, b: b};
	});
var $author$project$Jorn$Internal$Patch$RemoveProperty = F2(
	function (a, b) {
		return {$: 5, a: a, b: b};
	});
var $author$project$Jorn$Internal$Patch$SetAttribute = F3(
	function (a, b, c) {
		return {$: 2, a: a, b: b, c: c};
	});
var $author$project$Jorn$Internal$Patch$SetEvent = F3(
	function (a, b, c) {
		return {$: 6, a: a, b: b, c: c};
	});
var $author$project$Jorn$Internal$Patch$SetProperty = F3(
	function (a, b, c) {
		return {$: 4, a: a, b: b, c: c};
	});
var $elm$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _v0) {
				stepState:
				while (true) {
					var list = _v0.a;
					var result = _v0.b;
					if (!list.b) {
						return _Utils_Tuple2(
							list,
							A3(rightStep, rKey, rValue, result));
					} else {
						var _v2 = list.a;
						var lKey = _v2.a;
						var lValue = _v2.b;
						var rest = list.b;
						if (_Utils_cmp(lKey, rKey) < 0) {
							var $temp$rKey = rKey,
								$temp$rValue = rValue,
								$temp$_v0 = _Utils_Tuple2(
								rest,
								A3(leftStep, lKey, lValue, result));
							rKey = $temp$rKey;
							rValue = $temp$rValue;
							_v0 = $temp$_v0;
							continue stepState;
						} else {
							if (_Utils_cmp(lKey, rKey) > 0) {
								return _Utils_Tuple2(
									list,
									A3(rightStep, rKey, rValue, result));
							} else {
								return _Utils_Tuple2(
									rest,
									A4(bothStep, lKey, lValue, rValue, result));
							}
						}
					}
				}
			});
		var _v3 = A3(
			$elm$core$Dict$foldl,
			stepState,
			_Utils_Tuple2(
				$elm$core$Dict$toList(leftDict),
				initialResult),
			rightDict);
		var leftovers = _v3.a;
		var intermediateResult = _v3.b;
		return A3(
			$elm$core$List$foldl,
			F2(
				function (_v4, result) {
					var k = _v4.a;
					var v = _v4.b;
					return A3(leftStep, k, v, result);
				}),
			intermediateResult,
			leftovers);
	});
var $author$project$Jorn$Internal$Patch$diffDict = F6(
	function (same, set, remove, old, _new, acc) {
		return A6(
			$elm$core$Dict$merge,
			F3(
				function (key, _v0, a) {
					return A2(
						$elm$core$List$cons,
						remove(key),
						a);
				}),
			F4(
				function (key, o, n, a) {
					return A2(same, o, n) ? a : A2(
						$elm$core$List$cons,
						A2(set, key, n),
						a);
				}),
			F3(
				function (key, n, a) {
					return A2(
						$elm$core$List$cons,
						A2(set, key, n),
						a);
				}),
			old,
			_new,
			acc);
	});
var $author$project$Jorn$Internal$Patch$sameValue = F2(
	function (a, b) {
		return _Utils_eq(
			A2($elm$json$Json$Encode$encode, 0, a),
			A2($elm$json$Json$Encode$encode, 0, b));
	});
var $author$project$Jorn$Internal$Patch$diffFacts = F4(
	function (path, old, _new, acc) {
		return A6(
			$author$project$Jorn$Internal$Patch$diffDict,
			F2(
				function (_v0, _v1) {
					var a = _v0.a;
					var b = _v1.a;
					return _Utils_eq(a, b);
				}),
			F2(
				function (name, _v2) {
					var options = _v2.a;
					return A3($author$project$Jorn$Internal$Patch$SetEvent, path, name, options);
				}),
			$author$project$Jorn$Internal$Patch$RemoveEvent(path),
			old.P,
			_new.P,
			A6(
				$author$project$Jorn$Internal$Patch$diffDict,
				$author$project$Jorn$Internal$Patch$sameValue,
				$author$project$Jorn$Internal$Patch$SetProperty(path),
				$author$project$Jorn$Internal$Patch$RemoveProperty(path),
				old.N,
				_new.N,
				A6(
					$author$project$Jorn$Internal$Patch$diffDict,
					$elm$core$Basics$eq,
					$author$project$Jorn$Internal$Patch$SetAttribute(path),
					$author$project$Jorn$Internal$Patch$RemoveAttribute(path),
					old.I,
					_new.I,
					acc)));
	});
var $author$project$Jorn$Internal$Patch$diffChildren = F5(
	function (reversedPath, index, olds, news, acc) {
		diffChildren:
		while (true) {
			var _v4 = _Utils_Tuple2(olds, news);
			if (_v4.a.b) {
				if (_v4.b.b) {
					var _v5 = _v4.a;
					var o = _v5.a;
					var os = _v5.b;
					var _v6 = _v4.b;
					var n = _v6.a;
					var ns = _v6.b;
					var $temp$reversedPath = reversedPath,
						$temp$index = index + 1,
						$temp$olds = os,
						$temp$news = ns,
						$temp$acc = A4(
						$author$project$Jorn$Internal$Patch$diffHelp,
						A2($elm$core$List$cons, index, reversedPath),
						o,
						n,
						acc);
					reversedPath = $temp$reversedPath;
					index = $temp$index;
					olds = $temp$olds;
					news = $temp$news;
					acc = $temp$acc;
					continue diffChildren;
				} else {
					return A2(
						$elm$core$List$cons,
						A2(
							$author$project$Jorn$Internal$Patch$Truncate,
							$elm$core$List$reverse(reversedPath),
							index),
						acc);
				}
			} else {
				if (!_v4.b.b) {
					return acc;
				} else {
					return A2(
						$elm$core$List$cons,
						A2(
							$author$project$Jorn$Internal$Patch$Append,
							$elm$core$List$reverse(reversedPath),
							A2($elm$core$List$map, $author$project$Jorn$Internal$Vdom$toNode, news)),
						acc);
				}
			}
		}
	});
var $author$project$Jorn$Internal$Patch$diffHelp = F4(
	function (reversedPath, old, _new, acc) {
		var _v0 = _Utils_Tuple2(old, _new);
		_v0$2:
		while (true) {
			if (_v0.a.$ === 1) {
				if (_v0.b.$ === 1) {
					var a = _v0.a.a;
					var b = _v0.b.a;
					return _Utils_eq(a, b) ? acc : A2(
						$elm$core$List$cons,
						A2(
							$author$project$Jorn$Internal$Patch$SetText,
							$elm$core$List$reverse(reversedPath),
							b),
						acc);
				} else {
					break _v0$2;
				}
			} else {
				if (!_v0.b.$) {
					var _v1 = _v0.a;
					var oldNs = _v1.a;
					var oldTag = _v1.b;
					var oldAttrs = _v1.c;
					var oldKids = _v1.d;
					var _v2 = _v0.b;
					var newNs = _v2.a;
					var newTag = _v2.b;
					var newAttrs = _v2.c;
					var newKids = _v2.d;
					return (_Utils_eq(oldNs, newNs) && _Utils_eq(oldTag, newTag)) ? A5(
						$author$project$Jorn$Internal$Patch$diffChildren,
						reversedPath,
						0,
						oldKids,
						newKids,
						function () {
							var _v3 = _Utils_Tuple2(oldAttrs, newAttrs);
							if ((!_v3.a.b) && (!_v3.b.b)) {
								return acc;
							} else {
								return A4(
									$author$project$Jorn$Internal$Patch$diffFacts,
									$elm$core$List$reverse(reversedPath),
									$author$project$Jorn$Internal$Vdom$facts(oldAttrs),
									$author$project$Jorn$Internal$Vdom$facts(newAttrs),
									acc);
							}
						}()) : A2(
						$elm$core$List$cons,
						A2(
							$author$project$Jorn$Internal$Patch$Replace,
							$elm$core$List$reverse(reversedPath),
							$author$project$Jorn$Internal$Vdom$toNode(_new)),
						acc);
				} else {
					break _v0$2;
				}
			}
		}
		return A2(
			$elm$core$List$cons,
			A2(
				$author$project$Jorn$Internal$Patch$Replace,
				$elm$core$List$reverse(reversedPath),
				$author$project$Jorn$Internal$Vdom$toNode(_new)),
			acc);
	});
var $author$project$Jorn$Internal$Patch$diff = F2(
	function (old, _new) {
		return $elm$core$List$reverse(
			A4($author$project$Jorn$Internal$Patch$diffHelp, _List_Nil, old, _new, _List_Nil));
	});
var $author$project$Jorn$Patch$diff = $author$project$Jorn$Internal$Patch$diff;
var $elm$json$Json$Encode$int = _Json_wrap;
var $author$project$Jorn$Internal$Patch$op = F3(
	function (name, path, fields) {
		return $elm$json$Json$Encode$object(
			A2(
				$elm$core$List$cons,
				_Utils_Tuple2(
					'op',
					$elm$json$Json$Encode$string(name)),
				A2(
					$elm$core$List$cons,
					_Utils_Tuple2(
						'path',
						A2($elm$json$Json$Encode$list, $elm$json$Json$Encode$int, path)),
					fields)));
	});
var $author$project$Jorn$Internal$Patch$encodePatch = function (patch) {
	switch (patch.$) {
		case 0:
			var path = patch.a;
			var node = patch.b;
			return A3(
				$author$project$Jorn$Internal$Patch$op,
				'replace',
				path,
				_List_fromArray(
					[
						_Utils_Tuple2(
						'node',
						$author$project$Jorn$Internal$Vdom$encodeNode(node))
					]));
		case 1:
			var path = patch.a;
			var content = patch.b;
			return A3(
				$author$project$Jorn$Internal$Patch$op,
				'set-text',
				path,
				_List_fromArray(
					[
						_Utils_Tuple2(
						'text',
						$elm$json$Json$Encode$string(content))
					]));
		case 2:
			var path = patch.a;
			var name = patch.b;
			var value = patch.c;
			return A3(
				$author$project$Jorn$Internal$Patch$op,
				'set-attr',
				path,
				_List_fromArray(
					[
						_Utils_Tuple2(
						'name',
						$elm$json$Json$Encode$string(name)),
						_Utils_Tuple2(
						'value',
						$elm$json$Json$Encode$string(value))
					]));
		case 3:
			var path = patch.a;
			var name = patch.b;
			return A3(
				$author$project$Jorn$Internal$Patch$op,
				'remove-attr',
				path,
				_List_fromArray(
					[
						_Utils_Tuple2(
						'name',
						$elm$json$Json$Encode$string(name))
					]));
		case 4:
			var path = patch.a;
			var name = patch.b;
			var value = patch.c;
			return A3(
				$author$project$Jorn$Internal$Patch$op,
				'set-prop',
				path,
				_List_fromArray(
					[
						_Utils_Tuple2(
						'name',
						$elm$json$Json$Encode$string(name)),
						_Utils_Tuple2('value', value)
					]));
		case 5:
			var path = patch.a;
			var name = patch.b;
			return A3(
				$author$project$Jorn$Internal$Patch$op,
				'remove-prop',
				path,
				_List_fromArray(
					[
						_Utils_Tuple2(
						'name',
						$elm$json$Json$Encode$string(name))
					]));
		case 6:
			var path = patch.a;
			var name = patch.b;
			var options = patch.c;
			return A3(
				$author$project$Jorn$Internal$Patch$op,
				'set-event',
				path,
				_List_fromArray(
					[
						_Utils_Tuple2(
						'name',
						$elm$json$Json$Encode$string(name)),
						_Utils_Tuple2(
						'options',
						$author$project$Jorn$Internal$Vdom$encodeOptions(options))
					]));
		case 7:
			var path = patch.a;
			var name = patch.b;
			return A3(
				$author$project$Jorn$Internal$Patch$op,
				'remove-event',
				path,
				_List_fromArray(
					[
						_Utils_Tuple2(
						'name',
						$elm$json$Json$Encode$string(name))
					]));
		case 8:
			var path = patch.a;
			var nodes = patch.b;
			return A3(
				$author$project$Jorn$Internal$Patch$op,
				'append',
				path,
				_List_fromArray(
					[
						_Utils_Tuple2(
						'nodes',
						A2($elm$json$Json$Encode$list, $author$project$Jorn$Internal$Vdom$encodeNode, nodes))
					]));
		default:
			var path = patch.a;
			var length = patch.b;
			return A3(
				$author$project$Jorn$Internal$Patch$op,
				'truncate',
				path,
				_List_fromArray(
					[
						_Utils_Tuple2(
						'length',
						$elm$json$Json$Encode$int(length))
					]));
	}
};
var $author$project$Jorn$Internal$Patch$encode = function (patches) {
	return A2($elm$json$Json$Encode$list, $author$project$Jorn$Internal$Patch$encodePatch, patches);
};
var $author$project$Jorn$Patch$encode = $author$project$Jorn$Internal$Patch$encode;
var $author$project$Jorn$Internal$Event$pathToString = function (path) {
	return '[' + (A2(
		$elm$core$String$join,
		',',
		A2($elm$core$List$map, $elm$core$String$fromInt, path)) + ']');
};
var $author$project$Jorn$Internal$Event$errorToString = function (error) {
	switch (error.$) {
		case 0:
			var path = error.a;
			return 'No node at path ' + $author$project$Jorn$Internal$Event$pathToString(path);
		case 1:
			var path = error.a;
			var name = error.b;
			return 'No \"' + (name + ('\" handler at path ' + $author$project$Jorn$Internal$Event$pathToString(path)));
		default:
			var name = error.a;
			var decodeError = error.b;
			return 'The \"' + (name + ('\" handler failed to decode: ' + $elm$json$Json$Decode$errorToString(decodeError)));
	}
};
var $elm$core$Result$mapError = F2(
	function (f, result) {
		if (!result.$) {
			var v = result.a;
			return $elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return $elm$core$Result$Err(
				f(e));
		}
	});
var $author$project$Jorn$Internal$Event$DecodeFailed = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $author$project$Jorn$Internal$Event$NoHandler = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $author$project$Jorn$Internal$Event$NodeNotFound = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (!maybeValue.$) {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Jorn$Internal$Event$find = F2(
	function (path, element) {
		if (!path.b) {
			return $elm$core$Maybe$Just(element);
		} else {
			var index = path.a;
			var rest = path.b;
			if (!element.$) {
				var children = element.d;
				return (index < 0) ? $elm$core$Maybe$Nothing : A2(
					$elm$core$Maybe$andThen,
					$author$project$Jorn$Internal$Event$find(rest),
					$elm$core$List$head(
						A2($elm$core$List$drop, index, children)));
			} else {
				return $elm$core$Maybe$Nothing;
			}
		}
	});
var $author$project$Jorn$Internal$Event$route = F2(
	function (incoming, element) {
		var _v0 = A2($author$project$Jorn$Internal$Event$find, incoming.D, element);
		if (_v0.$ === 1) {
			return $elm$core$Result$Err(
				$author$project$Jorn$Internal$Event$NodeNotFound(incoming.D));
		} else {
			if (_v0.a.$ === 1) {
				return $elm$core$Result$Err(
					A2($author$project$Jorn$Internal$Event$NoHandler, incoming.D, incoming.C));
			} else {
				var _v1 = _v0.a;
				var attributes = _v1.c;
				var _v2 = A2(
					$elm$core$Dict$get,
					incoming.C,
					$author$project$Jorn$Internal$Vdom$facts(attributes).P);
				if (_v2.$ === 1) {
					return $elm$core$Result$Err(
						A2($author$project$Jorn$Internal$Event$NoHandler, incoming.D, incoming.C));
				} else {
					var _v3 = _v2.a;
					var handler = _v3.b;
					return A2(
						$elm$core$Result$mapError,
						$author$project$Jorn$Internal$Event$DecodeFailed(incoming.C),
						A2($elm$json$Json$Decode$decodeValue, handler, incoming.L));
				}
			}
		}
	});
var $author$project$Main$toClient = _Platform_outgoingPort('toClient', $elm$core$Basics$identity);
var $author$project$Main$send = F2(
	function (kind, payload) {
		return $author$project$Main$toClient(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(kind, payload)
					])));
	});
var $author$project$Main$update = F2(
	function (msg, model) {
		if (!msg.$) {
			return _Utils_update(
				model,
				{
					A: (!model.A) ? 1 : 0
				});
		} else {
			var filter = msg.a;
			return _Utils_update(
				model,
				{r: filter});
		}
	});
var $author$project$Jorn$Internal$Vdom$Attr = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$Jorn$Attribute$attribute = $author$project$Jorn$Internal$Vdom$Attr;
var $author$project$Jorn$Attribute$class = $author$project$Jorn$Attribute$attribute('class');
var $author$project$Jorn$Internal$Vdom$Element = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var $author$project$Jorn$Element$element = F3(
	function (tag, attributes, children) {
		return A4($author$project$Jorn$Internal$Vdom$Element, '', tag, attributes, children);
	});
var $author$project$Jorn$Element$Html$div = $author$project$Jorn$Element$element('div');
var $author$project$Jorn$Element$Html$h2 = $author$project$Jorn$Element$element('h2');
var $author$project$Jorn$Attribute$id = $author$project$Jorn$Attribute$attribute('id');
var $author$project$Jorn$Element$Html$ol = $author$project$Jorn$Element$element('ol');
var $author$project$Jorn$Element$Html$p = $author$project$Jorn$Element$element('p');
var $author$project$Jorn$Element$Html$section = $author$project$Jorn$Element$element('section');
var $author$project$Jorn$Internal$Vdom$Text = function (a) {
	return {$: 1, a: a};
};
var $author$project$Jorn$Element$text = $author$project$Jorn$Internal$Vdom$Text;
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $author$project$Jorn$Attribute$classes = function (classList) {
	return $author$project$Jorn$Attribute$class(
		A2(
			$elm$core$String$join,
			' ',
			A2(
				$elm$core$List$map,
				$elm$core$Tuple$first,
				A2($elm$core$List$filter, $elm$core$Tuple$second, classList))));
};
var $author$project$Jorn$Element$Html$li = $author$project$Jorn$Element$element('li');
var $author$project$Main$tracks = _List_fromArray(
	['Pavement', '916', 'Take the Wheel', '360 No Scope', 'Statistically', 'Way You Aren\'t']);
var $author$project$Main$trackRows = (($elm$core$List$length($author$project$Main$tracks) + 1) / 2) | 0;
var $author$project$Main$track = F2(
	function (index, title) {
		return A2(
			$author$project$Jorn$Element$Html$li,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$classes(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'col-top',
							(!index) || _Utils_eq(index, $author$project$Main$trackRows))
						]))
				]),
			_List_fromArray(
				[
					A3(
					$author$project$Jorn$Element$element,
					'b',
					_List_Nil,
					_List_fromArray(
						[
							$author$project$Jorn$Element$text(title)
						]))
				]));
	});
var $author$project$Main$band = A2(
	$author$project$Jorn$Element$Html$section,
	_List_fromArray(
		[
			$author$project$Jorn$Attribute$class('band'),
			$author$project$Jorn$Attribute$id('band')
		]),
	_List_fromArray(
		[
			A2(
			$author$project$Jorn$Element$Html$div,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('wrap band-in')
				]),
			_List_fromArray(
				[
					A2(
					$author$project$Jorn$Element$Html$p,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('eyebrow')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('05 / off the clock')
						])),
					A2(
					$author$project$Jorn$Element$Html$h2,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('band-name')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('The Comedowns')
						])),
					A2(
					$author$project$Jorn$Element$Html$p,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('band-sub')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('Chicago punk / midwest emo. Somewhere between loud and sincere.')
						])),
					A2(
					$author$project$Jorn$Element$Html$ol,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('tracks'),
							A2(
							$author$project$Jorn$Attribute$attribute,
							'style',
							'--track-rows: ' + $elm$core$String$fromInt($author$project$Main$trackRows))
						]),
					A2($elm$core$List$indexedMap, $author$project$Main$track, $author$project$Main$tracks)),
					A2(
					$author$project$Jorn$Element$Html$p,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('band-note')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('The rest of this site is the day job. This is the night one. ' + ('The other off-hours constant: four years as a Big with ' + 'Big Brothers Big Sisters.'))
						]))
				]))
		]));
var $author$project$Jorn$Element$Html$h3 = $author$project$Jorn$Element$element('h3');
var $author$project$Main$claimItem = function (_v0) {
	var heading = _v0.a;
	var body = _v0.b;
	return A2(
		$author$project$Jorn$Element$Html$li,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$author$project$Jorn$Element$Html$h3,
				_List_Nil,
				_List_fromArray(
					[
						$author$project$Jorn$Element$text(heading)
					])),
				A2(
				$author$project$Jorn$Element$Html$p,
				_List_Nil,
				_List_fromArray(
					[
						$author$project$Jorn$Element$text(body)
					]))
			]));
};
var $author$project$Main$claim = A2(
	$author$project$Jorn$Element$Html$section,
	_List_fromArray(
		[
			$author$project$Jorn$Attribute$class('section wrap split'),
			$author$project$Jorn$Attribute$id('claim')
		]),
	_List_fromArray(
		[
			A2(
			$author$project$Jorn$Element$Html$div,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('split-head')
				]),
			_List_fromArray(
				[
					A2(
					$author$project$Jorn$Element$Html$p,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('eyebrow')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('01 / the claim')
						])),
					A2(
					$author$project$Jorn$Element$Html$h2,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('h2')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('Most AI dies in procurement and uptime, not in accuracy.')
						]))
				])),
			A2(
			$author$project$Jorn$Element$Html$ol,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('claims split-body')
				]),
			A2(
				$elm$core$List$map,
				$author$project$Main$claimItem,
				_List_fromArray(
					[
						_Utils_Tuple2('Ship the 0→1, then make it survive.', 'A platform is a demo on day one and an uptime problem ' + ('on day ninety. I have taken one from the first commit ' + ('to about twenty customer deployments, which is a ' + 'different job than the one people pitch.'))),
						_Utils_Tuple2('Replace the API call when the API call is the bottleneck.', 'GPT-dependent detections moved to in-house models, and ' + ('one feature\'s spend dropped 6×. A new segmentation model ' + ('took inference from 400 ms to 26 ms and GPU load at five ' + ('stations from 100% to about 30%. Same accuracy ' + 'requirement, different bill.')))),
						_Utils_Tuple2('Own the boring parts.', 'ISO 27001:2022 from a standing start. SOC 2 Type I ' + ('readiness. RLS multi-tenant Postgres. Hardened Linux on ' + ('x86, micro-x86 and ARM. Three-minute median first ' + ('response. Upkeep is hard, and it is also most of the ' + 'job.')))),
						_Utils_Tuple2('Grow the people, then get out of the way.', 'As the team went from solo to nine across time zones, my ' + ('week went from 80% code to 20%. The job became getting ' + ('other people to their best work, and owning my mistakes ' + 'out loud so they could own theirs.')))
					])))
		]));
var $author$project$Jorn$Element$Html$a = $author$project$Jorn$Element$element('a');
var $author$project$Jorn$Attribute$href = $author$project$Jorn$Attribute$attribute('href');
var $author$project$Jorn$Element$Html$span = $author$project$Jorn$Element$element('span');
var $author$project$Main$contactLine = F3(
	function (key, label, href) {
		return A2(
			$author$project$Jorn$Element$Html$li,
			_List_Nil,
			_List_fromArray(
				[
					A2(
					$author$project$Jorn$Element$Html$span,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('links-k')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text(key)
						])),
					A2(
					$author$project$Jorn$Element$Html$a,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$href(href)
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text(label)
						]))
				]));
	});
var $author$project$Jorn$Element$Html$ul = $author$project$Jorn$Element$element('ul');
var $author$project$Main$contact = A2(
	$author$project$Jorn$Element$Html$section,
	_List_fromArray(
		[
			$author$project$Jorn$Attribute$class('section wrap'),
			$author$project$Jorn$Attribute$id('contact')
		]),
	_List_fromArray(
		[
			A2(
			$author$project$Jorn$Element$Html$p,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('eyebrow')
				]),
			_List_fromArray(
				[
					$author$project$Jorn$Element$text('06 / contact')
				])),
			A2(
			$author$project$Jorn$Element$Html$h2,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('h2')
				]),
			_List_fromArray(
				[
					$author$project$Jorn$Element$text('Got something worth breaking?')
				])),
			A2(
			$author$project$Jorn$Element$Html$p,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('contact-lede')
				]),
			_List_fromArray(
				[
					$author$project$Jorn$Element$text('Forward deployed and applied AI roles, technical leadership, or a ' + ('deployment that will not stay up. Chicago-based, happy to be on ' + 'site with customers. I read all of it and I answer.'))
				])),
			A2(
			$author$project$Jorn$Element$Html$ul,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('links')
				]),
			_List_fromArray(
				[
					A3($author$project$Main$contactLine, 'email', 'bhorsey16@gmail.com', 'mailto:bhorsey16@gmail.com'),
					A3($author$project$Main$contactLine, 'github', 'github.com/bazylhorsey', 'https://github.com/bazylhorsey'),
					A3($author$project$Main$contactLine, 'linkedin', 'in/bazyl-horsey', 'https://www.linkedin.com/in/bazyl-horsey-075506139'),
					A3($author$project$Main$contactLine, 'orcid', '0009-0000-4566-0406', 'https://orcid.org/0009-0000-4566-0406')
				]))
		]));
var $author$project$Jorn$Element$Html$footer = $author$project$Jorn$Element$element('footer');
var $author$project$Main$foot = A2(
	$author$project$Jorn$Element$Html$footer,
	_List_fromArray(
		[
			$author$project$Jorn$Attribute$class('foot')
		]),
	_List_fromArray(
		[
			A2(
			$author$project$Jorn$Element$Html$div,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('wrap foot-in')
				]),
			_List_fromArray(
				[
					A2(
					$author$project$Jorn$Element$Html$p,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('foot-line')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('Upkeep is hard. I do it anyway.')
						])),
					A2(
					$author$project$Jorn$Element$Html$p,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('foot-sub')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('Every element on this page is a value in an Elm program. ' + ('Jorn diffs the view and ships only what changed, so ' + 'there is no hand-written markup and no framework.'))
						])),
					A2(
					$author$project$Jorn$Element$Html$p,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('foot-sub foot-fine')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('Written in Elm against github.com/bazylhorsey/jorn. ' + ('One stylesheet, one compiled script, zero ' + 'dependencies.'))
						]))
				]))
		]));
var $elm$core$String$fromFloat = _String_fromNumber;
var $author$project$Main$num = $elm$core$String$fromFloat;
var $author$project$Jorn$Element$namespaced = F4(
	function (namespace, tag, attributes, children) {
		return A4($author$project$Jorn$Internal$Vdom$Element, namespace, tag, attributes, children);
	});
var $author$project$Main$svgNs = 'http://www.w3.org/2000/svg';
var $author$project$Main$svg = $author$project$Jorn$Element$namespaced($author$project$Main$svgNs);
var $author$project$Main$svgText = F4(
	function (cls, x, y, label) {
		return A3(
			$author$project$Main$svg,
			'text',
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class(cls),
					A2(
					$author$project$Jorn$Attribute$attribute,
					'x',
					$author$project$Main$num(x)),
					A2(
					$author$project$Jorn$Attribute$attribute,
					'y',
					$author$project$Main$num(y))
				]),
			_List_fromArray(
				[
					$author$project$Jorn$Element$text(label)
				]));
	});
var $author$project$Main$dgEdge = F2(
	function (y, label) {
		return _List_fromArray(
			[
				A3(
				$author$project$Main$svg,
				'line',
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('dg-edge'),
						A2($author$project$Jorn$Attribute$attribute, 'x1', '160'),
						A2(
						$author$project$Jorn$Attribute$attribute,
						'y1',
						$author$project$Main$num(y)),
						A2($author$project$Jorn$Attribute$attribute, 'x2', '160'),
						A2(
						$author$project$Jorn$Attribute$attribute,
						'y2',
						$author$project$Main$num(y + 40))
					]),
				_List_Nil),
				A3(
				$author$project$Main$svg,
				'path',
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('dg-head'),
						A2(
						$author$project$Jorn$Attribute$attribute,
						'd',
						'M154 ' + ($author$project$Main$num(y + 38) + (' L160 ' + ($author$project$Main$num(y + 47) + (' L166 ' + ($author$project$Main$num(y + 38) + ' Z'))))))
					]),
				_List_Nil),
				A4($author$project$Main$svgText, 'dg-label', 174, y + 28, label)
			]);
	});
var $author$project$Main$dgLoop = _List_fromArray(
	[
		A3(
		$author$project$Main$svg,
		'path',
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('dg-loop'),
				A2($author$project$Jorn$Attribute$attribute, 'd', 'M320 436 H366 V196 H331')
			]),
		_List_Nil),
		A3(
		$author$project$Main$svg,
		'path',
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('dg-loop-head'),
				A2($author$project$Jorn$Attribute$attribute, 'd', 'M333 190 L324 196 L333 202 Z')
			]),
		_List_Nil),
		A3(
		$author$project$Main$svg,
		'text',
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('dg-loop-label'),
				A2($author$project$Jorn$Attribute$attribute, 'transform', 'translate(386 316) rotate(-90)'),
				A2($author$project$Jorn$Attribute$attribute, 'text-anchor', 'middle')
			]),
		_List_fromArray(
			[
				$author$project$Jorn$Element$text('misses → retrain → re-pin')
			]))
	]);
var $author$project$Main$span = function (part) {
	if (!part.$) {
		var t = part.a;
		return A3(
			$author$project$Main$svg,
			'tspan',
			_List_Nil,
			_List_fromArray(
				[
					$author$project$Jorn$Element$text(t)
				]));
	} else {
		var t = part.a;
		return A3(
			$author$project$Main$svg,
			'tspan',
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('dg-hot')
				]),
			_List_fromArray(
				[
					$author$project$Jorn$Element$text(t)
				]));
	}
};
var $author$project$Main$dgNode = F3(
	function (y, title, sub) {
		return _List_fromArray(
			[
				A3(
				$author$project$Main$svg,
				'rect',
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('dg-shadow'),
						A2($author$project$Jorn$Attribute$attribute, 'x', '6'),
						A2(
						$author$project$Jorn$Attribute$attribute,
						'y',
						$author$project$Main$num(y + 5)),
						A2($author$project$Jorn$Attribute$attribute, 'width', '318'),
						A2($author$project$Jorn$Attribute$attribute, 'height', '72')
					]),
				_List_Nil),
				A3(
				$author$project$Main$svg,
				'rect',
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('dg-box'),
						A2($author$project$Jorn$Attribute$attribute, 'x', '1.5'),
						A2(
						$author$project$Jorn$Attribute$attribute,
						'y',
						$author$project$Main$num(y)),
						A2($author$project$Jorn$Attribute$attribute, 'width', '318'),
						A2($author$project$Jorn$Attribute$attribute, 'height', '72')
					]),
				_List_Nil),
				A3(
				$author$project$Main$svg,
				'rect',
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('dg-tick'),
						A2($author$project$Jorn$Attribute$attribute, 'x', '18'),
						A2(
						$author$project$Jorn$Attribute$attribute,
						'y',
						$author$project$Main$num(y + 21)),
						A2($author$project$Jorn$Attribute$attribute, 'width', '8'),
						A2($author$project$Jorn$Attribute$attribute, 'height', '8')
					]),
				_List_Nil),
				A4($author$project$Main$svgText, 'dg-title', 34, y + 30, title),
				A3(
				$author$project$Main$svg,
				'text',
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('dg-sub'),
						A2($author$project$Jorn$Attribute$attribute, 'x', '18'),
						A2(
						$author$project$Jorn$Attribute$attribute,
						'y',
						$author$project$Main$num(y + 54))
					]),
				A2($elm$core$List$map, $author$project$Main$span, sub))
			]);
	});
var $author$project$Main$Hot = function (a) {
	return {$: 1, a: a};
};
var $author$project$Main$hot = $author$project$Main$Hot;
var $author$project$Main$Plain = function (a) {
	return {$: 0, a: a};
};
var $author$project$Main$plain = $author$project$Main$Plain;
var $author$project$Main$diagram = A3(
	$author$project$Main$svg,
	'svg',
	_List_fromArray(
		[
			$author$project$Jorn$Attribute$class('diagram'),
			A2($author$project$Jorn$Attribute$attribute, 'viewBox', '0 0 400 480'),
			A2($author$project$Jorn$Attribute$attribute, 'role', 'img'),
			A2($author$project$Jorn$Attribute$attribute, 'aria-labelledby', 'dg-title')
		]),
	_Utils_ap(
		_List_fromArray(
			[
				A3(
				$author$project$Main$svg,
				'title',
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$id('dg-title')
					]),
				_List_fromArray(
					[
						$author$project$Jorn$Element$text('The napkin sketch: the customer\'s site feeds edge inference, ' + ('which feeds the platform, which feeds agents and the people ' + 'who approve their work. Misses loop back into retraining.'))
					])),
				A4($author$project$Main$svgText, 'dg-cap', 1, 14, 'FIG. 1 / THE NAPKIN, WRAPPED IN CSS')
			]),
		_Utils_ap(
			A3(
				$author$project$Main$dgNode,
				40,
				'THEIR SITE',
				_List_fromArray(
					[
						$author$project$Main$plain('their cameras, network and IT')
					])),
			_Utils_ap(
				A2($author$project$Main$dgEdge, 112, 'video, sensors'),
				_Utils_ap(
					A3(
						$author$project$Main$dgNode,
						160,
						'EDGE INFERENCE',
						_List_fromArray(
							[
								$author$project$Main$plain('x86 · ARM · TensorRT · '),
								$author$project$Main$hot('26 ms')
							])),
					_Utils_ap(
						A2($author$project$Main$dgEdge, 232, 'events, evidence'),
						_Utils_ap(
							A3(
								$author$project$Main$dgNode,
								280,
								'PLATFORM',
								_List_fromArray(
									[
										$author$project$Main$plain('model registry, pinned per customer')
									])),
							_Utils_ap(
								A2($author$project$Main$dgEdge, 352, 'claims, alerts'),
								_Utils_ap(
									A3(
										$author$project$Main$dgNode,
										400,
										'AGENTS + PEOPLE',
										_List_fromArray(
											[
												$author$project$Main$plain('agents draft, a human approves')
											])),
									$author$project$Main$dgLoop)))))))));
var $author$project$Jorn$Element$Html$h1 = $author$project$Jorn$Element$element('h1');
var $author$project$Main$heroCopy = _List_fromArray(
	[
		A2(
		$author$project$Jorn$Element$Html$p,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('status')
			]),
		_List_fromArray(
			[
				A2(
				$author$project$Jorn$Element$Html$span,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('dot')
					]),
				_List_Nil),
				$author$project$Jorn$Element$text('Chicago, IL'),
				$author$project$Jorn$Element$text(' / Open to work')
			])),
		A2(
		$author$project$Jorn$Element$Html$h1,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('name')
			]),
		_List_fromArray(
			[
				$author$project$Jorn$Element$text('Bazyl '),
				A3($author$project$Jorn$Element$element, 'br', _List_Nil, _List_Nil),
				$author$project$Jorn$Element$text('Horsey'),
				A2(
				$author$project$Jorn$Element$Html$span,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('caret')
					]),
				_List_Nil)
			])),
		A2(
		$author$project$Jorn$Element$Html$p,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('lede')
			]),
		_List_fromArray(
			[
				$author$project$Jorn$Element$text('Serial co-founder and two-time VC-backed startup CTO. Applied AI: agentic ' + 'systems and edge inference.')
			])),
		A2(
		$author$project$Jorn$Element$Html$p,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('claim-line')
			]),
		_List_fromArray(
			[
				$author$project$Jorn$Element$text('I build AI that has to work in production, not in a notebook.')
			])),
		A2(
		$author$project$Jorn$Element$Html$div,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('hero-actions')
			]),
		_List_fromArray(
			[
				A2(
				$author$project$Jorn$Element$Html$a,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('btn btn-solid'),
						$author$project$Jorn$Attribute$href('#work')
					]),
				_List_fromArray(
					[
						$author$project$Jorn$Element$text('What I\'ve shipped')
					])),
				A2(
				$author$project$Jorn$Element$Html$a,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('btn'),
						$author$project$Jorn$Attribute$href('mailto:bhorsey16@gmail.com')
					]),
				_List_fromArray(
					[
						$author$project$Jorn$Element$text('bhorsey16@gmail.com')
					]))
			]))
	]);
var $author$project$Main$hero = A2(
	$author$project$Jorn$Element$Html$section,
	_List_fromArray(
		[
			$author$project$Jorn$Attribute$class('hero wrap')
		]),
	_List_fromArray(
		[
			A2(
			$author$project$Jorn$Element$Html$div,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('hero-copy')
				]),
			$author$project$Main$heroCopy),
			$author$project$Main$diagram
		]));
var $author$project$Jorn$Element$Html$main_ = $author$project$Jorn$Element$element('main');
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $author$project$Main$metric = function (item) {
	return A2(
		$author$project$Jorn$Element$Html$div,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('num')
			]),
		_List_fromArray(
			[
				A3(
				$author$project$Jorn$Element$element,
				'b',
				_List_Nil,
				_List_fromArray(
					[
						$author$project$Jorn$Element$text(item.j)
					])),
				A2(
				$author$project$Jorn$Element$Html$span,
				_List_Nil,
				_List_fromArray(
					[
						$author$project$Jorn$Element$text(item.i)
					]))
			]));
};
var $author$project$Main$figures = function (items) {
	return $elm$core$List$isEmpty(items) ? _List_Nil : _List_fromArray(
		[
			A2(
			$author$project$Jorn$Element$Html$div,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('nums nums--inline')
				]),
			A2($elm$core$List$map, $author$project$Main$metric, items))
		]);
};
var $author$project$Main$roleItem = function (role) {
	return A2(
		$author$project$Jorn$Element$Html$li,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$author$project$Jorn$Element$Html$div,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('path-when')
					]),
				_List_fromArray(
					[
						A3(
						$author$project$Jorn$Element$element,
						'b',
						_List_Nil,
						_List_fromArray(
							[
								$author$project$Jorn$Element$text(role.z)
							])),
						A2(
						$author$project$Jorn$Element$Html$span,
						_List_Nil,
						_List_fromArray(
							[
								$author$project$Jorn$Element$text(role.y)
							]))
					])),
				A2(
				$author$project$Jorn$Element$Html$div,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('path-what')
					]),
				A2(
					$elm$core$List$cons,
					A2(
						$author$project$Jorn$Element$Html$h3,
						_List_Nil,
						_List_fromArray(
							[
								$author$project$Jorn$Element$text(role.w),
								A2(
								$author$project$Jorn$Element$Html$span,
								_List_fromArray(
									[
										$author$project$Jorn$Attribute$class('path-role')
									]),
								_List_fromArray(
									[
										$author$project$Jorn$Element$text(role.g)
									]))
							])),
					_Utils_ap(
						A2(
							$elm$core$List$map,
							function (line) {
								return A2(
									$author$project$Jorn$Element$Html$p,
									_List_Nil,
									_List_fromArray(
										[
											$author$project$Jorn$Element$text(line)
										]));
							},
							role.e),
						$author$project$Main$figures(role.q))))
			]));
};
var $author$project$Main$roles = _List_fromArray(
	[
		{
		e: _List_fromArray(
			['Techstars \'22, then a $4M seed led by Rackhouse. Took the ' + ('platform from first commit to about twenty customer ' + ('deployments across five product lines, then built the ' + ('plug-and-play inspection product behind the pivot: installs ' + ('in a day, works with the cameras and systems a site already ' + 'has.')))), 'Grew engineering from solo to nine across time zones. As CISO, ' + ('built the ISMS from nothing to ISO 27001:2022 and SOC 2 Type I ' + ('readiness. Principal investigator on a $1M+ DoD-funded MxD ' + 'safety AI project.'))]),
		q: _List_Nil,
		w: 'Arvist',
		y: 'Chicago, IL',
		z: '2023→now',
		g: 'Co-founder & CTO, now Technical Advisor'
	},
		{
		e: _List_fromArray(
			['Smart-locker and mobility IoT, now Accessa, backed by Jason ' + ('Calacanis with a $1M pre-seed. Part-time through college, CTO ' + ('from 2021. Led a team of five, rebuilt a legacy PHP app as ' + ('FastAPI and React services on AWS, and built the BLE SDKs and ' + ('the BLE and LTE module behind the 2020 Smart Locker launch, ' + ('which became the core business. The software was the easy ' + 'half.')))))]),
		q: _List_Nil,
		w: 'Koloni',
		y: 'Chicago, IL',
		z: '2019→2022',
		g: 'Software Manager → Application Manager → CTO'
	},
		{
		e: _List_fromArray(
			['First startup out of Buena Vista\'s Foundry incubator. Wound it ' + ('down in 2021 and brought two of its engineers to Koloni, which ' + ('I count as the best outcome any of my companies had. Earlier: ' + ('the app for Match-Learn-Launch, a $175,000 Google.org Impact ' + 'Challenge winner.')))]),
		q: _List_Nil,
		w: 'Levity',
		y: 'Storm Lake, IA',
		z: '2020→2021',
		g: 'Co-founder & CEO'
	},
		{
		e: _List_fromArray(
			['Dean\'s List. President of the Robotics Club. Collegiate wrestler, ' + ('which explains more about how I run engineering than any ' + 'conference talk does.')]),
		q: _List_Nil,
		w: 'Buena Vista University',
		y: 'Storm Lake, IA',
		z: '2016→2020',
		g: 'BS Computer Science, minor in Communications'
	}
	]);
var $author$project$Main$section = F4(
	function (anchor, eyebrow, heading, children) {
		return A2(
			$author$project$Jorn$Element$Html$section,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('section wrap'),
					$author$project$Jorn$Attribute$id(anchor)
				]),
			_List_fromArray(
				[
					A2(
					$author$project$Jorn$Element$Html$p,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('eyebrow')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text(eyebrow)
						])),
					A2(
					$author$project$Jorn$Element$Html$h2,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('h2')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text(heading)
						])),
					A3($author$project$Jorn$Element$element, 'div', _List_Nil, children)
				]));
	});
var $author$project$Main$path = A4(
	$author$project$Main$section,
	'path',
	'03 / path',
	'Where the scar tissue came from.',
	_List_fromArray(
		[
			A2(
			$author$project$Jorn$Element$Html$ol,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('path')
				]),
			A2($elm$core$List$map, $author$project$Main$roleItem, $author$project$Main$roles))
		]));
var $author$project$Main$metrics = _List_fromArray(
	[
		{i: 'of customer incidents traced to site power, network or hardware, not our code', j: '90%+'},
		{i: 'days, median time to close a bug', j: '10.9→3'},
		{i: 'ms per segmentation inference, new model', j: '400→26'},
		{i: 'GPU load across five edge stations', j: '100→30%'},
		{i: 'less GPT spend on one feature, same output', j: '6×'},
		{i: 'versioned releases in a single quarter', j: '131'},
		{i: 'median first response to a customer', j: '3 min'},
		{i: 'engineers on a global team, from solo', j: '9'}
	]);
var $author$project$Main$receipts = A2(
	$author$project$Jorn$Element$Html$section,
	_List_fromArray(
		[
			$author$project$Jorn$Attribute$class('receipts'),
			$author$project$Jorn$Attribute$id('receipts')
		]),
	_List_fromArray(
		[
			A2(
			$author$project$Jorn$Element$Html$div,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('wrap')
				]),
			_List_fromArray(
				[
					A2(
					$author$project$Jorn$Element$Html$p,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('eyebrow')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('01 / the receipts')
						])),
					A2(
					$author$project$Jorn$Element$Html$h2,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('h2')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('Numbers, not adjectives.')
						])),
					A2(
					$author$project$Jorn$Element$Html$div,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('nums')
						]),
					A2($elm$core$List$map, $author$project$Main$metric, $author$project$Main$metrics))
				]))
		]));
var $author$project$Main$PickFilter = function (a) {
	return {$: 1, a: a};
};
var $author$project$Jorn$Element$Html$button = $author$project$Jorn$Element$element('button');
var $author$project$Jorn$Internal$Vdom$On = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $author$project$Jorn$Event$on = F2(
	function (name, decoder) {
		return A2($author$project$Jorn$Internal$Vdom$On, name, decoder);
	});
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $author$project$Jorn$Event$onClick = function (msg) {
	return A2(
		$author$project$Jorn$Event$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $author$project$Jorn$Attribute$type_ = $author$project$Jorn$Attribute$attribute('type');
var $author$project$Main$filterButton = F2(
	function (current, _v0) {
		var filter = _v0.a;
		var label = _v0.b;
		return A2(
			$author$project$Jorn$Element$Html$button,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class(
					_Utils_eq(filter, current) ? 'filter is-on' : 'filter'),
					$author$project$Jorn$Attribute$type_('button'),
					$author$project$Jorn$Event$onClick(
					$author$project$Main$PickFilter(filter))
				]),
			_List_fromArray(
				[
					$author$project$Jorn$Element$text(label)
				]));
	});
var $author$project$Main$Experiment = 3;
var $author$project$Main$Framework = 0;
var $author$project$Main$Only = function (a) {
	return {$: 1, a: a};
};
var $author$project$Main$Tool = 1;
var $author$project$Main$Upstream = 2;
var $author$project$Main$filters = _List_fromArray(
	[
		_Utils_Tuple2($author$project$Main$Everything, 'everything'),
		_Utils_Tuple2(
		$author$project$Main$Only(0),
		'frameworks'),
		_Utils_Tuple2(
		$author$project$Main$Only(1),
		'tools'),
		_Utils_Tuple2(
		$author$project$Main$Only(2),
		'upstream'),
		_Utils_Tuple2(
		$author$project$Main$Only(3),
		'experiments')
	]);
var $author$project$Main$statusLabel = function (status) {
	switch (status) {
		case 0:
			return 'done';
		case 1:
			return 'next';
		default:
			return 'planned';
	}
};
var $author$project$Main$statusName = function (status) {
	switch (status) {
		case 0:
			return 'done';
		case 1:
			return 'next';
		default:
			return 'plan';
	}
};
var $author$project$Main$stageRow = function (stage) {
	return A3(
		$author$project$Jorn$Element$element,
		'tr',
		_List_Nil,
		_List_fromArray(
			[
				A3(
				$author$project$Jorn$Element$element,
				'td',
				_List_Nil,
				_List_fromArray(
					[
						$author$project$Jorn$Element$text(stage.o)
					])),
				A3(
				$author$project$Jorn$Element$element,
				'td',
				_List_Nil,
				_List_fromArray(
					[
						$author$project$Jorn$Element$text(stage.n)
					])),
				A3(
				$author$project$Jorn$Element$element,
				'td',
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$author$project$Jorn$Element$Html$span,
						_List_fromArray(
							[
								$author$project$Jorn$Attribute$class(
								'chip chip-' + $author$project$Main$statusName(stage.l))
							]),
						_List_fromArray(
							[
								$author$project$Jorn$Element$text(
								$author$project$Main$statusLabel(stage.l))
							]))
					]))
			]));
};
var $author$project$Main$stageTable = function (stages) {
	return A3(
		$author$project$Jorn$Element$element,
		'table',
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('roadmap')
			]),
		_List_fromArray(
			[
				A3(
				$author$project$Jorn$Element$element,
				'tbody',
				_List_Nil,
				A2($elm$core$List$map, $author$project$Main$stageRow, stages))
			]));
};
var $author$project$Main$statusTag = function (category) {
	switch (category) {
		case 0:
			return _List_fromArray(
				['current']);
		case 2:
			return _List_fromArray(
				['upstream']);
		default:
			return _List_Nil;
	}
};
var $author$project$Main$tag = function (label) {
	return A2(
		$author$project$Jorn$Element$Html$span,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('tag')
			]),
		_List_fromArray(
			[
				$author$project$Jorn$Element$text(label)
			]));
};
var $author$project$Main$itemCard = F2(
	function (filter, item) {
		return A2(
			$author$project$Jorn$Element$Html$li,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$classes(
					_List_fromArray(
						[
							_Utils_Tuple2('card', true),
							_Utils_Tuple2(
							'card-feature',
							(!item.f) && _Utils_eq(filter, $author$project$Main$Everything))
						]))
				]),
			_List_fromArray(
				[
					A2(
					$author$project$Jorn$Element$Html$div,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('card-head')
						]),
					A2(
						$elm$core$List$cons,
						A2(
							$author$project$Jorn$Element$Html$h3,
							_List_Nil,
							_List_fromArray(
								[
									$author$project$Jorn$Element$text(item.C)
								])),
						A2(
							$elm$core$List$map,
							$author$project$Main$tag,
							_Utils_ap(
								item.m,
								$author$project$Main$statusTag(item.f))))),
					(!item.f) ? A2(
					$author$project$Jorn$Element$Html$p,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('card-quote')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text(item.h)
						])) : A2(
					$author$project$Jorn$Element$Html$p,
					_List_Nil,
					_List_fromArray(
						[
							$author$project$Jorn$Element$text(item.h)
						])),
					$elm$core$List$isEmpty(item.k) ? A3($author$project$Jorn$Element$element, 'span', _List_Nil, _List_Nil) : $author$project$Main$stageTable(item.k),
					function () {
					var _v0 = item.a;
					if (!_v0.$) {
						var href = _v0.a;
						return A2(
							$author$project$Jorn$Element$Html$a,
							_List_fromArray(
								[
									$author$project$Jorn$Attribute$class('link'),
									$author$project$Jorn$Attribute$href(href)
								]),
							_List_fromArray(
								[
									$author$project$Jorn$Element$text(href)
								]));
					} else {
						return A3($author$project$Jorn$Element$element, 'span', _List_Nil, _List_Nil);
					}
				}()
				]));
	});
var $author$project$Main$kept = F2(
	function (filter, category) {
		if (!filter.$) {
			return true;
		} else {
			var wanted = filter.a;
			return _Utils_eq(wanted, category);
		}
	});
var $author$project$Main$Done = 0;
var $author$project$Main$Next = 1;
var $author$project$Main$Planned = 2;
var $author$project$Main$jornStages = _List_fromArray(
	[
		{n: 'Pure Elm vdom, diff, wire protocol, event routing', o: '1', l: 0},
		{n: 'Browser patcher, applies patches to the real DOM', o: '2', l: 0},
		{n: 'Full HTML/SVG/MathML, keyed lists, effects, runtime', o: '3', l: 1},
		{n: 'Server runtime over a websocket', o: '4', l: 2},
		{n: 'Generated, compiler-checked encoders for shared types', o: '5', l: 2},
		{n: 'Session snapshots and typed migrations across deploys', o: '6', l: 2}
	]);
var $author$project$Main$work = _List_fromArray(
	[
		{
		h: 'Write your UI once in Elm and decide at deploy time where each ' + ('piece runs: browser, server, or both. Pure Elm virtual DOM, a ' + ('diff that runs anywhere, a JSON wire protocol and a ' + ('dependency-free browser patcher. No kernel code, no fork. This ' + 'page runs on it.'))),
		f: 0,
		a: $elm$core$Maybe$Just('https://github.com/bazylhorsey/jorn'),
		C: 'Jorn',
		k: $author$project$Main$jornStages,
		m: _List_fromArray(
			['elm', 'v0.0'])
	},
		{
		h: 'An MCP server that connects local and remote Obsidian vaults to ' + ('desktop AI tools: multi-vault switching, graph analysis, hybrid ' + 'search and backlinks.'),
		f: 1,
		a: $elm$core$Maybe$Just('https://github.com/bazylhorsey/obsidian-mcp-server'),
		C: 'obsidian-mcp-server',
		k: _List_Nil,
		m: _List_fromArray(
			['typescript', '22 stars'])
	},
		{
		h: 'A proposal to add typed stdin prompts to the Rust standard ' + ('library (rust-lang/rust#117852, RFC 3196). What upstream ' + 'actually feels like from the outside.'),
		f: 2,
		a: $elm$core$Maybe$Just('https://github.com/bazylhorsey/prompt-rust'),
		C: 'prompt-rust',
		k: _List_Nil,
		m: _List_fromArray(
			['rust'])
	},
		{
		h: 'A Rust take on Phoenix LiveView, built to learn the ' + ('browser-versus-server trade-off from the implementer\'s side. ' + 'The only way to have an opinion about it.'),
		f: 1,
		a: $elm$core$Maybe$Nothing,
		C: 'Aethos',
		k: _List_Nil,
		m: _List_fromArray(
			['rust'])
	},
		{
		h: 'Hayleigh Thompson\'s Gleam web framework. Four open PRs, including ' + ('a 337-line fix for server component context subscriptions and ' + ('a CI workflow for main. Upkeep is hard. Apparently I do it ' + 'anyway.')),
		f: 2,
		a: $elm$core$Maybe$Just('https://github.com/lustre-labs/lustre/pulls?q=is%3Apr+author%3Abazylhorsey'),
		C: 'Lustre',
		k: _List_Nil,
		m: _List_fromArray(
			['gleam'])
	},
		{
		h: 'The open-source NVR. A merged fix to its auth cookie pattern and ' + ('an open one for a shared-memory leak on skipped frames. Same ' + 'class of bug as the day job, in someone else\'s codebase.'),
		f: 2,
		a: $elm$core$Maybe$Just('https://github.com/blakeblackshear/frigate/pulls?q=is%3Apr+author%3Abazylhorsey'),
		C: 'Frigate',
		k: _List_Nil,
		m: _List_fromArray(
			['python'])
	},
		{
		h: 'A ChatGPT 3.0-era Lovable, presented at the OpenAI Hackathon in ' + 'Chicago, 2022. Kept because it is funny and it was early.',
		f: 3,
		a: $elm$core$Maybe$Just('https://github.com/bazylhorsey/astonish'),
		C: 'astonish',
		k: _List_Nil,
		m: _List_fromArray(
			['python'])
	}
	]);
var $author$project$Main$visibleWork = function (filter) {
	return A2(
		$elm$core$List$filter,
		function (item) {
			return A2($author$project$Main$kept, filter, item.f);
		},
		$author$project$Main$work);
};
var $author$project$Main$shipped = function (model) {
	return A2(
		$author$project$Jorn$Element$Html$section,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('section wrap'),
				$author$project$Jorn$Attribute$id('work')
			]),
		_List_fromArray(
			[
				A2(
				$author$project$Jorn$Element$Html$p,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('eyebrow')
					]),
				_List_fromArray(
					[
						$author$project$Jorn$Element$text('02 / work')
					])),
				A2(
				$author$project$Jorn$Element$Html$h2,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('h2')
					]),
				_List_fromArray(
					[
						$author$project$Jorn$Element$text('Things that exist and run.')
					])),
				A2(
				$author$project$Jorn$Element$Html$div,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('filters')
					]),
				A2(
					$elm$core$List$map,
					$author$project$Main$filterButton(model.r),
					$author$project$Main$filters)),
				A2(
				$author$project$Jorn$Element$Html$ul,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('work')
					]),
				A2(
					$elm$core$List$map,
					$author$project$Main$itemCard(model.r),
					$author$project$Main$visibleWork(model.r)))
			]));
};
var $author$project$Main$themeName = function (theme) {
	if (!theme) {
		return 'paper';
	} else {
		return 'night';
	}
};
var $author$project$Main$ToggleTheme = {$: 0};
var $author$project$Jorn$Element$Html$header = $author$project$Jorn$Element$element('header');
var $author$project$Jorn$Element$Html$nav = $author$project$Jorn$Element$element('nav');
var $author$project$Main$navLink = function (_v0) {
	var anchor = _v0.a;
	var label = _v0.b;
	return A2(
		$author$project$Jorn$Element$Html$a,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$href(anchor)
			]),
		_List_fromArray(
			[
				$author$project$Jorn$Element$text(label)
			]));
};
var $author$project$Main$topbar = function (model) {
	return A2(
		$author$project$Jorn$Element$Html$header,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('topbar')
			]),
		_List_fromArray(
			[
				A2(
				$author$project$Jorn$Element$Html$div,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('wrap topbar-in')
					]),
				_List_fromArray(
					[
						A2(
						$author$project$Jorn$Element$Html$span,
						_List_fromArray(
							[
								$author$project$Jorn$Attribute$class('mark')
							]),
						_List_fromArray(
							[
								$author$project$Jorn$Element$text('Bazyl Horsey')
							])),
						A2(
						$author$project$Jorn$Element$Html$nav,
						_List_fromArray(
							[
								$author$project$Jorn$Attribute$class('topnav')
							]),
						A2(
							$elm$core$List$map,
							$author$project$Main$navLink,
							_List_fromArray(
								[
									_Utils_Tuple2('#claim', 'claim'),
									_Utils_Tuple2('#work', 'work'),
									_Utils_Tuple2('#path', 'path'),
									_Utils_Tuple2('#writing', 'writing'),
									_Utils_Tuple2('#band', 'off hours'),
									_Utils_Tuple2('#contact', 'contact')
								]))),
						A2(
						$author$project$Jorn$Element$Html$button,
						_List_fromArray(
							[
								$author$project$Jorn$Attribute$class('theme'),
								$author$project$Jorn$Attribute$type_('button'),
								$author$project$Jorn$Event$onClick($author$project$Main$ToggleTheme)
							]),
						_List_fromArray(
							[
								$author$project$Jorn$Element$text(
								(!model.A) ? 'night' : 'day')
							]))
					]))
			]));
};
var $author$project$Main$groupLabel = function (label) {
	return A2(
		$author$project$Jorn$Element$Html$p,
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('group-label')
			]),
		_List_fromArray(
			[
				$author$project$Jorn$Element$text(label)
			]));
};
var $author$project$Main$paper = {e: 'Frontiers in Sustainability 5:1416964. Modeled roughly 50% lower ' + ('emissions by rerouting livestock between brooders and ' + ('finishers with a Gurobi optimization over distance, ' + ('exclusivity, and capacity. The notebook is public, which is ' + 'the point of publishing.'))), t: 'Implementing concepts from green logistics in the turkey production supply chain', a: 'https://doi.org/10.3389/frsus.2024.1416964', u: 'peer reviewed / 2024 / second author', v: 'doi:10.3389/frsus.2024.1416964'};
var $author$project$Main$paperCard = A3(
	$author$project$Jorn$Element$element,
	'article',
	_List_fromArray(
		[
			$author$project$Jorn$Attribute$class('write write--paper')
		]),
	_List_fromArray(
		[
			A2(
			$author$project$Jorn$Element$Html$p,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('write-meta')
				]),
			_List_fromArray(
				[
					$author$project$Jorn$Element$text($author$project$Main$paper.u)
				])),
			A2(
			$author$project$Jorn$Element$Html$h3,
			_List_Nil,
			_List_fromArray(
				[
					$author$project$Jorn$Element$text($author$project$Main$paper.t)
				])),
			A2(
			$author$project$Jorn$Element$Html$p,
			_List_Nil,
			_List_fromArray(
				[
					$author$project$Jorn$Element$text($author$project$Main$paper.e)
				])),
			A2(
			$author$project$Jorn$Element$Html$div,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('write-links')
				]),
			_List_fromArray(
				[
					A2(
					$author$project$Jorn$Element$Html$a,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('link'),
							$author$project$Jorn$Attribute$href($author$project$Main$paper.a)
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text($author$project$Main$paper.v)
						])),
					A2(
					$author$project$Jorn$Element$Html$a,
					_List_fromArray(
						[
							$author$project$Jorn$Attribute$class('link'),
							$author$project$Jorn$Attribute$href('https://github.com/bazylhorsey/livestock-logistic-optimizer')
						]),
					_List_fromArray(
						[
							$author$project$Jorn$Element$text('the notebook, gurobi MIP')
						]))
				]))
		]));
var $author$project$Main$piece = function (item) {
	return A3(
		$author$project$Jorn$Element$element,
		'article',
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class('write')
			]),
		_List_fromArray(
			[
				A2(
				$author$project$Jorn$Element$Html$p,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('write-meta')
					]),
				_List_fromArray(
					[
						$author$project$Jorn$Element$text(item.u)
					])),
				A2(
				$author$project$Jorn$Element$Html$h3,
				_List_Nil,
				_List_fromArray(
					[
						$author$project$Jorn$Element$text(item.t)
					])),
				A2(
				$author$project$Jorn$Element$Html$p,
				_List_Nil,
				_List_fromArray(
					[
						$author$project$Jorn$Element$text(item.e)
					])),
				A2(
				$author$project$Jorn$Element$Html$a,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('link'),
						$author$project$Jorn$Attribute$href(item.a)
					]),
				_List_fromArray(
					[
						$author$project$Jorn$Element$text(item.v)
					]))
			]));
};
var $author$project$Main$podcasts = _List_fromArray(
	[
		{e: 'Academic burnout through to running engineering at Arvist. Why ' + ('scrappy beats flashy when you are building a team, and what ' + ('most CTOs get wrong about leadership. The episode title is the ' + 'whole review.')), t: 'Doesn\'t sugarcoat it', a: 'https://youtu.be/mk7CKtatU8U', u: 'software leaders uncensored / with steve taplin', v: 'youtu.be/mk7CKtatU8U'},
		{e: 'Encord\'s show, hosted by their co-founder. Going deep on AI in ' + ('logistics: what it takes to get a model out of a notebook and ' + ('onto a dock, why the old boring methods still win more often ' + ('than the shiny new thing, and where quality assurance in ' + 'warehousing is heading.'))), t: 'Building Arvist, and what AI actually needs in a warehouse', a: 'https://encord.com/deep-learning-leaders/', u: 'deep learning leaders / with eric landau', v: 'deep learning leaders'}
	]);
var $author$project$Main$postRow = function (post) {
	return A2(
		$author$project$Jorn$Element$Html$li,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$author$project$Jorn$Element$Html$a,
				_List_fromArray(
					[
						$author$project$Jorn$Attribute$class('post'),
						$author$project$Jorn$Attribute$href(post.a)
					]),
				_List_fromArray(
					[
						A2(
						$author$project$Jorn$Element$Html$span,
						_List_fromArray(
							[
								$author$project$Jorn$Attribute$class('post-meta')
							]),
						_List_fromArray(
							[
								A3(
								$author$project$Jorn$Element$element,
								'b',
								_List_Nil,
								_List_fromArray(
									[
										$author$project$Jorn$Element$text(post.p)
									])),
								A2(
								$author$project$Jorn$Element$Html$span,
								_List_Nil,
								_List_fromArray(
									[
										$author$project$Jorn$Element$text(post.x)
									]))
							])),
						A2(
						$author$project$Jorn$Element$Html$span,
						_List_fromArray(
							[
								$author$project$Jorn$Attribute$class('post-body')
							]),
						_List_fromArray(
							[
								A3(
								$author$project$Jorn$Element$element,
								'b',
								_List_fromArray(
									[
										$author$project$Jorn$Attribute$class('post-title')
									]),
								_List_fromArray(
									[
										$author$project$Jorn$Element$text(post.g)
									])),
								A2(
								$author$project$Jorn$Element$Html$span,
								_List_fromArray(
									[
										$author$project$Jorn$Attribute$class('post-gist')
									]),
								_List_fromArray(
									[
										$author$project$Jorn$Element$text(post.s)
									]))
							])),
						A2(
						$author$project$Jorn$Element$Html$span,
						_List_fromArray(
							[
								$author$project$Jorn$Attribute$class('post-go')
							]),
						_List_fromArray(
							[
								$author$project$Jorn$Element$text('→')
							]))
					]))
			]));
};
var $author$project$Main$posts = _List_fromArray(
	[
		{p: '2026.08', s: 'Building software got cheap, so small niches pay now. The moat moves ' + 'from owning the platform to adapting fastest to each operation.', a: 'https://arvist.ai/vertical-monopoly/', x: 'arvist blog', g: 'Why vertical monopoly doesn\'t work for warehouse software anymore'},
		{p: '2026.08', s: 'Quotes price the connection. The time and money go into mapping data ' + 'that doesn\'t line up and the scope nobody wrote down.', a: 'https://arvist.ai/why-your-integration-quote-is-wrong/', x: 'arvist blog', g: 'Why your integration quote is wrong'},
		{p: '2021.01', s: 'Fresh out of school and building smart lockers at Koloni: hardware, ' + 'firmware and apps that all have to ship together.', a: 'https://bazyl-25260.medium.com/lessons-learned-in-iot-product-development-405b569e5b4c', x: 'medium', g: 'Lessons learned in IoT product development'},
		{p: '2020.11', s: 'Where shared lockers, scooters and bikes were headed, from inside the business.', a: 'https://bazyl-25260.medium.com/the-future-of-sharing-and-micro-mobility-d63b26fa405', x: 'medium', g: 'The future of sharing and micro-mobility'}
	]);
var $author$project$Main$writing = A4(
	$author$project$Main$section,
	'writing',
	'04 / writing & talking',
	'Said out loud, on the record.',
	_List_fromArray(
		[
			$author$project$Main$groupLabel('Research'),
			$author$project$Main$paperCard,
			$author$project$Main$groupLabel('Podcasts'),
			A2(
			$author$project$Jorn$Element$Html$div,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('writes')
				]),
			A2($elm$core$List$map, $author$project$Main$piece, $author$project$Main$podcasts)),
			$author$project$Main$groupLabel('Posts'),
			A2(
			$author$project$Jorn$Element$Html$ul,
			_List_fromArray(
				[
					$author$project$Jorn$Attribute$class('posts')
				]),
			A2($elm$core$List$map, $author$project$Main$postRow, $author$project$Main$posts))
		]));
var $author$project$Main$view = function (model) {
	return A3(
		$author$project$Jorn$Element$element,
		'div',
		_List_fromArray(
			[
				$author$project$Jorn$Attribute$class(
				'page page--' + $author$project$Main$themeName(model.A))
			]),
		_List_fromArray(
			[
				$author$project$Main$topbar(model),
				A2(
				$author$project$Jorn$Element$Html$main_,
				_List_Nil,
				_List_fromArray(
					[
						$author$project$Main$hero,
						$author$project$Main$claim,
						$author$project$Main$receipts,
						$author$project$Main$shipped(model),
						$author$project$Main$path,
						$author$project$Main$writing,
						$author$project$Main$band,
						$author$project$Main$contact
					])),
				$author$project$Main$foot
			]));
};
var $author$project$Main$receive = F2(
	function (raw, model) {
		var routed = A2(
			$elm$core$Result$andThen,
			function (incoming) {
				return A2(
					$elm$core$Result$mapError,
					$author$project$Jorn$Internal$Event$errorToString,
					A2(
						$author$project$Jorn$Internal$Event$route,
						incoming,
						$author$project$Main$view(model)));
			},
			A2(
				$elm$core$Result$mapError,
				$elm$json$Json$Decode$errorToString,
				A2($elm$json$Json$Decode$decodeValue, $author$project$Jorn$Internal$Event$decoder, raw)));
		if (!routed.$) {
			var msg = routed.a;
			var next = A2($author$project$Main$update, msg, model);
			return _Utils_Tuple2(
				next,
				A2(
					$author$project$Main$send,
					'patches',
					$author$project$Jorn$Patch$encode(
						A2(
							$author$project$Jorn$Patch$diff,
							$author$project$Main$view(model),
							$author$project$Main$view(next)))));
		} else {
			var problem = routed.a;
			return _Utils_Tuple2(
				model,
				A2(
					$author$project$Main$send,
					'error',
					$elm$json$Json$Encode$string(problem)));
		}
	});
var $elm$core$Platform$worker = _Platform_worker;
var $author$project$Main$main = $elm$core$Platform$worker(
	{
		Q: function (flags) {
			var model = $author$project$Main$init(flags);
			return _Utils_Tuple2(
				model,
				A2(
					$author$project$Main$send,
					'mount',
					$author$project$Jorn$Patch$encodeHtml(
						$author$project$Main$view(model))));
		},
		R: function (_v0) {
			return $author$project$Main$fromClient($elm$core$Basics$identity);
		},
		S: $author$project$Main$receive
	});
_Platform_export({'Main':{'init':$author$project$Main$main($elm$json$Json$Decode$value)(0)}});}(this));