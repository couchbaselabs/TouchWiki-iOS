var SYNC_HOSTNAME=process.env.SYNC_HOSTNAME,
  dbName = "wiki",
  designUrl = "http://"+SYNC_HOSTNAME+":4984/basecouch/_design/channels",
  bucketDesignUrl = "http://"+SYNC_HOSTNAME+":8091/couchBase/basecouch/_design/wiki",
  bucketWikiMembersView = "http://"+SYNC_HOSTNAME+":8092/basecouch/_design/"+dbName+"/_view/by_members",
  baseCouchAuth = "http://"+SYNC_HOSTNAME+":4985",
  channelPass = Math.random().toString(20).slice(2),
  baseDbUrl = "http://channelServer:"+channelPass+"@"+SYNC_HOSTNAME+":4984/basecouch",
  channelChanges = "http://channelServer:"+channelPass+"@"+SYNC_HOSTNAME+
    ":4984/basecouch/_changes?filter=basecouch/bychannel&channels=wikis&feed=longpoll"
  ;

if (!SYNC_HOSTNAME) {
  console.log(("launch like: SYNC_HOSTNAME=myhost.local node serve.js"));
  process.exit(-1);
}

var coux = require("coux"),
  http = require("http"),
  url = require("url"),
  _ = require("underscore"),
  async = require("async");

// turn off guest access
coux.put(baseCouchAuth+"/GUEST", {
  name: "GUEST", password : "GUEST",
  channels : []
}, function(err, ok) {
  if (err) {
    console.log("couldn't turn off GUEST access", err);
    process.exit(-1);
  }
});

function installDDoc(url, doc, cb) {
  console.log("installing "+url)
  coux(url, function(err, old) {
    if (!err) {
      doc._rev = old._rev;
    }
    coux.put(url, doc, function(err, ok){
      if (err) {
        throw("couldn't push doc " +url+" : "+JSON.stringify(err));
      }
      console.log("pushed doc", doc._id);
    });
  });
}

function channelMap(doc) {
  var ch = doc.wiki_id;
  if (ch) {
    sync("wiki-"+ch);
  }
  if (doc.members && doc.owner_id) {
    sync("wikis");
    sync("wikis-"+doc.owner_id);
    ms = doc.members.split(" ");
    for (i = ms.length - 1; i >= 0; i--) {
      if (ms[i]) {
        sync("wikis-"+ms[i]);
      }
    }
  }
}

// install sync function
installDDoc(designUrl, {
    _id : "_design/channels",
    channelmap : channelMap.toString()
  }, function(err, ok){
    if (err) {
      throw(["couldn't push sync ddoc", err]);
    } else {
      console.log("pushed sync ddoc");
    }
  });


var ByMembersBucketView = function (doc, meta) {
  var i, ms, ch = doc.wiki_id;
  if (ch && doc.members) {
    ms = doc.members.split(" ");
    for (i = ms.length - 1; i >= 0; i--) {
      if (ms[i]) emit([ms[i], ch], doc.title);
    }
    if (doc.owner_id) {emit([doc.owner_id, ch], doc.title);}
  }
}

// install bucket design docs
installDDoc(bucketDesignUrl, {
    _id : "_design/wiki",
    views : {
      "by_members" : {reduce : "_count", map : ByMembersBucketView.toString()}
    }
  }, function(err, ok){
    if (err) {
      throw("couldn't push bucket ddoc" + err);
    } else {
      console.log("pushed bucket ddoc");
    }
  });

var since = 0;
function watchForWikis(url, cb) {
  coux(url+'&since='+since, function(err, ok){
    if (err) {
      throw(err)
    } else {
      since = ok.last_seq;
      async.map(ok.results, function(r, next){
        coux([baseDbUrl, r.id], next);
      }, cb);
      watchForWikis(url, cb);
    }
  });
}

function setChannelsForUser(user, channels, cb){
  coux([baseCouchAuth, user], function(err, doc) {
    if (err || doc.statusCode == 404) {
      console.log("missing user", user);
      return cb();
    } else {
      // console.log("doc", doc)
      channels.push("wikis-"+user);
      doc.channels = channels;
      // console.log("put", user, doc);
      coux.put([baseCouchAuth, user], doc, cb);
    }
  })
};

function updateUsers(users) {
  async.forEach(users, function(user, cb){
    coux([bucketWikiMembersView,
        {stale:false,group:true,connection_timeout:60000,
          start_key : [user], end_key : [user, {}]}], function(err, view){
            if (err) return cb(err);
            var channels = view.rows.map(function(r){return "wiki-"+r.key[1]});
            setChannelsForUser(user, channels, cb);
          });
  }, function(err, done) {
    if (err) {
      throw(err)
    } else {
      console.log("users updated");
    }
  });
}

// watch basecouch for channel changes
coux.put(baseCouchAuth+"/channelServer", {
  name: "channelServer", password : channelPass,
  channels : ["wikis"]
}, function(err, ok) {
  if (err) {
    console.log("couldn't turn on channelServer access", err);
    process.exit(-1);
  } else {
    watchForWikis(channelChanges, function(err, docs){
      if (err) {
        console.log('changes err', channelChanges)
        throw(err)
      } else {
        // for all the users mentioned in the wiki doc,
        // update their channels list
        var docUsers, users = [];
        docs.forEach(function(doc){
          if (doc.members && doc.owner_id) {
            docUsers = doc.members.split(' ');
            docUsers.push(doc.owner_id);
            users = users.concat(docUsers);
          }
        });
        updateUsers(_.uniq(users))
      }
    })
  }
});

// serve http for user signup
// get credentials request, set credentials if they aren't set yet

function handleSignup (req, res) {
  function handleSignupBody(body) {
    var data = JSON.parse(body); // {user : "name", pass : "s3cr3t"}
    coux([baseCouchAuth, data.user], function(err, doc) {
      console.log("get user", data.user, err, doc.statusCode)
      if (doc.statusCode == 404) {
        console.log("new user", data);
        coux.put([baseCouchAuth, data.user], {
          name : data.user,
          password : data.pass,
          channels : []
        }, function(err, ok) {
          if (err) {
            console.log("new user put err",err);
            res.statusCode = 500;
            res.end("new user err")
          } else {
            console.log("new user put",data.user, ok);
            res.statusCode = 200;
            res.end("new user");
          }

        });
      } else {
        res.statusCode = 401;
        res.end("can't set credentials for existing user");
      }
    })
  }

  if (req.method != "POST") {
    res.statusCode = 406;
    res.end("POST required")
  }

  var chunk = "";
  req.on('data', function(data) {
    console.log(chunk += data.toString());
  });

  req.on('end', function() {
    // empty 200 OK response for now
    if (chunk) {
      handleSignupBody(chunk)
    } else {
      console.log("empty body");
    }
  });
}



var app = http.createServer(function(req, res){
  var path = url.parse(req.url).pathname;
  if (/^\/signup/.test(path)) {
    handleSignup(req, res);
  }
}).listen(3000);


