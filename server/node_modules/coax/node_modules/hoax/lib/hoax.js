/*
 * hoax
 * https://github.com/jchris/hoax
 *
 * Copyright (c) 2013 Chris Anderson
 * Licensed under the Apache license.
 */
var pax = require("pax"),
  request = require("request"),
  jreq = request.defaults({json:true});

function makeHoaxCallback(cb) {
  return function(err, res, body){
    if (err) {
      cb(err, res, body);
    } else {
      if (res.statusCode >= 400) {
        cb(body || res.statusCode, res);
      } else {
        cb(null, body);
      }
    }
  };
}

function processArguments(myPax, urlOrOpts, data, cb, verb) {
  var opts = {}, newPax = myPax;
  if (typeof urlOrOpts === 'function') {
    cb = urlOrOpts;
    data = null;
    urlOrOpts = null;
  } else {
    if (urlOrOpts.uri || urlOrOpts.url) {
      newPax = myPax(urlOrOpts.uri || urlOrOpts.url);
    } else {
      if (typeof data === 'function') {
        // we have only 2 args
        // the first is data if it is not an array
        // and the verb is put or post
        cb = data;
        data = null;
        if ((verb === "put" || verb === "post") &&
          (typeof urlOrOpts !== "string" &&
            Object.prototype.toString.call(urlOrOpts) !== '[object Array]')) {
            data = urlOrOpts;
        } else {
          newPax = myPax(urlOrOpts);
        }
      } else {
        newPax = myPax(urlOrOpts);
      }
    }
  }
  opts.headers = {'content-type': 'application/json'};
  opts.uri = newPax.toString();
  if (data) {
    opts.body = JSON.stringify(data);
  }
  return [opts, cb, newPax];
}

function makeHoax(myPax, verb) {
  var newHoax = function(opts, data, xcb) {
    var args = processArguments(myPax, opts, data, xcb, verb),
      reqOpts = args[0], // includes uri, body
      cb = args[1],
      newPax = args[2];
    if (cb) {
      if (verb) {
        return jreq[verb](reqOpts, makeHoaxCallback(cb));
      } else {
        return jreq(reqOpts, makeHoaxCallback(cb));
      }
    } else {
      return makeHoax(newPax, verb);
    }
  };
  if (!verb) {
    "get put post head del".split(" ").forEach(function(v){
      newHoax[v] = makeHoax(myPax, v);
    });
  }
  return newHoax;
}

var Hoax = module.exports = makeHoax(pax());

Hoax.makeHoax = makeHoax;
