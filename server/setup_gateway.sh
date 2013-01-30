#!/bin/bash

http PUT :4984/wiki/_design/channels channelmap='function(doc){\
    sync(doc.owner_id);\
    sync(doc.members);\
    sync(doc.wiki_id);}'

http PUT :4985/snej password=foo email=jens@mooseyard.com channels:='["snej"]'
http PUT :4985/jchris password=foo email=jchris@couchbase.com channels:='["jchris"]'
