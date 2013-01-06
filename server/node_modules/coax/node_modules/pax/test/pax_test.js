var pax = require('../lib/pax.js');


var db, doc;
exports['can curry'] = {
  setUp: function(done) {
    // setup here
    db = pax(["http://localhost:5984","test-pax"]);
    doc = db("my-doc");
    done();
  },
  'is stringable': function(test) {
    test.expect(2);
    // tests here
    test.equal(db.toString(), 'http://localhost:5984/test-pax', 'should be awesome.');
    test.equal(doc.toString(), 'http://localhost:5984/test-pax/my-doc', 'should be awesome.');
    test.done();
  }
};

exports['can curry params'] = {
  setUp: function(done) {
    // setup here
    db = pax(["http://localhost:5984","test-pax", {myKey : "valuable"}]);
    doc = db(["my-doc", {more : "data"}]);
    done();
  },
  'is stringable': function(test) {
    test.expect(2);
    // tests here
    test.equal(db.toString(), 'http://localhost:5984/test-pax?myKey=valuable', 'should be immutable.');
    test.equal(doc.toString(), 'http://localhost:5984/test-pax/my-doc?myKey=valuable&more=data', 'should be awesome.');
    test.done();
  }
};

exports['can curry only params'] = {
  setUp: function(done) {
    // setup here
    db = pax(["http://localhost:5984","test-pax", {myKey : "valuable"}]);
    doc = db({more : "data"});
    done();
  },
  'is stringable': function(test) {
    test.expect(2);
    // tests here
    test.equal(db.toString(), 'http://localhost:5984/test-pax?myKey=valuable', 'should be immutable.');
    test.equal(doc.toString(), 'http://localhost:5984/test-pax?myKey=valuable&more=data', 'should be awesome.');
    test.done();
  }
};


exports['custom getQuery handler'] = {
  setUp: function(done) {
    // setup here

    db = pax(["http://localhost:5984","test-pax", {myKey : "valuable"}]);

    db.getQuery = function(params) {
      params.foobar = "true";
      return params;
    };

    doc = db({more : "data"});

    done();
  },
  'is stringable': function(test) {
    test.expect(3);
    // tests here
    test.equal(pax("http://localhost:5984/test-pax").toString(), 'http://localhost:5984/test-pax', 'should be normal.');
    test.equal(db.toString(), 'http://localhost:5984/test-pax?myKey=valuable&foobar=true', 'should be custom.');
    test.equal(doc.toString(), 'http://localhost:5984/test-pax?myKey=valuable&more=data&foobar=true', 'should be curried.');
    test.done();
  }
};

exports['global getQuery handler'] = {
  setUp: function(done) {
    // setup here
    pax.getQuery = function(q) {
      q.global = true;
      return q;
    };
    db = pax(["http://localhost:5984","test-pax", {myKey : "valuable"}]);
    doc = db({more : "data"});

    done();
  },
  'is stringable': function(test) {
    test.expect(2);
    // tests here
    test.equal(db.toString(), 'http://localhost:5984/test-pax?myKey=valuable&global=true', 'should be custom.');
    test.equal(doc.toString(), 'http://localhost:5984/test-pax?myKey=valuable&more=data&global=true', 'should be curried.');
    pax.getQuery = false;
    test.done();
  }
};


exports['with encodings'] = {
  setUp: function(done) {
    // setup here
    db = pax(["http://localhost:5984","test-p/x", {myKey : "valu#ble"}]);
    doc = db("my-d$c");
    done();
  },
  'is stringable': function(test) {
    test.expect(2);
    // tests here
    test.equal(db.toString(), 'http://localhost:5984/test-p%2Fx?myKey=valu%23ble', 'should be awesome.');
    test.equal(doc.toString(), 'http://localhost:5984/test-p%2Fx/my-d%24c?myKey=valu%23ble', 'should be awesome.');
    test.done();
  }
};


exports['dirty input'] = {
  setUp: function(done) {
    // setup here
    db = pax("http://localhost:5984/test-pax", {myKey : "valuable"});
    doc = db("my-doc", {more : "data"});
    done();
  },
  'is stringable': function(test) {
    test.expect(2);
    // tests here
    test.equal(db.toString(), 'http://localhost:5984/test-pax?myKey=valuable', 'should be awesome.');
    test.equal(doc.toString(), 'http://localhost:5984/test-pax/my-doc?myKey=valuable&more=data', 'should be awesome.');
    test.done();
  }
};
