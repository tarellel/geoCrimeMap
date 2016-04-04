var crimeFile = ("data/latest.csv").toString();

// keeping count for all the types of crimes that recently occurred
crimes = {
  'alcohol': 0,
  'assault': 0,
  'breakins': 0,
  'disorder': 0,
  'drugs': 0,
  'property': 0,
  'robbery': 0,
  'theft': 0,
  'etc': 0
}

// add 1 to the current crime type
function setCrime (type) {
  crimes[type] += 1;
}

function getCrime(type){
  console.log(crimes[type]);
  crimes[type];
}

// Provide your access token
L.mapbox.accessToken = '<-- access_token -->';

// Create a map in the div #map
var map = L.mapbox.map('map', 'tarellel.eef55dd3',{
                        attributionControl: false,
                        infoControl: true
                  })
                  .setView([36.73964, -108.20538], 14);

omnivore.csv(crimeFile)
  .on('ready', function(layer) {
    this.eachLayer(function(marker){
      var icon = "";
      var markerColor = "#607D8B"; //"#8BC34A"; / FF5722 | 607D8B
      // determine icon type based on the crime
      switch(marker.toGeoJSON().properties.type){
        case "Assault":
          icon = 'baseball';
          markerColor = '#fc4353';
          setCrime('assault');
          break;
        case "Breaking & Entering":
          icon = 'entrance';
          markerColor = '#fc4353';
          setCrime('breakins');
          break;
        case "Disorder":
          icon = 'roadblock';
          markerColor = '#fc4353';
          setCrime('disorder');
          break;
        case "Drugs":
          icon = 'pharmacy';
          markerColor = '#03C9A9';
          setCrime('drugs');
          break;
        case "Liquor":
          icon = 'alcohol-shop';
          markerColor = "#00BCD4";
          setCrime('alcohol');
          break;
        case "Property Crime":
          icon = 'hairdresser';
          markerColor = '#F9B24F';
          setCrime('property');
          break;
        case 'Robbery':
          icon = 'pitch';
          setCrime('robbery');
          break;
        case "Theft":
          icon = 'shop';
          setCrime('theft');
          break;
        case 'Theft from Vehicle':
        case "Theft of Vehicle":
          icon = 'car';
          markerColor = '#E61875';
          setCrime('theft');
          break;
        default:
          icon = 'police';
          setCrime('etc');
      }

      marker.setIcon(L.mapbox.marker.icon({
        'title': marker.toGeoJSON().properties.title,
        //'marker-color': '#fc4353',
        'marker-color': markerColor,
        "marker-size": "medium",
        "marker-symbol": icon
      }));

      // Bind a popup to each icon based on the same properties
      marker.bindPopup(
        '<div class="crimeType">' + marker.toGeoJSON().properties.type + '</div>' +
        '<b>Case:</b> ' + marker.toGeoJSON().properties.case_id + '<br>' +
        '<b>Desc:</b> ' + marker.toGeoJSON().properties.desc
      );
    });
    setCrimeCounts(crimes);
  })
  .addTo(map);
