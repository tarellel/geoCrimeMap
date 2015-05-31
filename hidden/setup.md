###

The most important factor is a [Mapbox](https://www.mapbox.com/) access_token is required for displaying the map and getting [lat,long] locations.

* Add the access_token to  `crimegeo.rb` on line [81] `"access_token"`
* You will also need to add the access_token to `/assets/js/app.js` on line [71] `"L.mapbox.accessToken"`

Both these variable assignments are pretty self explanatory seeing as how they are labeled "access_token"
