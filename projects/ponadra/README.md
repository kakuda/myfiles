# ponadra

A Clojure library designed to ... well, that part is up to you.

## Usage

title
artist
image
link
preview-url
preview-file
category
releasedate
similars (coll)
clj


http://127.0.0.1:28017/ponadra/songs/?limit=-10
mongo ponadra
db.songs.drop();
db.songs.count();
db.songs.find().limit(1);
db.songs.find( {artist: "BEGIN"}, {clj: 0} );

db.songs.find( {song-id: 'mzaf_1065082439662221839'}, {clj: 0} );

db.songs.find( { similars : { $ne : [] } }, {clj: 0} );
db.songs.find( { similars : { $ne : [] } }).count();

db.mycolls.find( { emails: { $ne: [] } } );

FIXME

## License

Copyright © 2012 FIXME

Distributed under the Eclipse Public License, the same as Clojure.
