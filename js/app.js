var date = new Date();
//var today = new Date(date.getTime() - date.getTimezoneOffset()*60*1000);
//var dateString = today.toISOString().slice(0, 10);
//var crimeFile = ("data/" + dateString + ".csv").toString();
var crimeFile = ("data/latest.csv").toString();

// keeping count for all the types of crimes that recently occurred
crimes = {
  'assault': 0,
  'breakins': 0,
  'disorder': 0,
  'drugs': 0,
  'liquor': 0,
  'property': 0,
  'robbery': 0,
  'theft': 0,
  'etc': 0
}


function setCrime (type) {
  crimes[type] += 1;
}

function getCrime(type){
  console.log(crimes[type]);
  crimes[type];
}

function setupChart(crimes){
  var ctx = document.getElementById("myChart").getContext("2d");
  var data = {
    labels: ["Assaults", "Breakins","Drugs", "Liquor", "Thefts", "Robberies", "Disorder", "Property Damage","Etc."],
    datasets: [
        {
            label: "Crimes Commited",
            fillColor: "rgba(220,220,220,0.5)",
            strokeColor: "rgba(220,220,220,0.8)",
            highlightFill: "rgba(220,220,220,0.75)",
            highlightStroke: "rgba(220,220,220,1)",
            data: [crimes['assault'], crimes['breakins'], crimes['drugs'], crimes['liquor'], crimes['theft'], crimes['robbery'], crimes['disorder'], crimes['property'], crimes['etc']]
        },
    ]
  };
  var myBarChart = new Chart(ctx).Bar(data);
  var i = 0;
  for(i = 0; i < 9; i++){
    if (i % 2 == 0){
      // Blueish
      //myBarChart.datasets[0].bars[i].fillColor = "#00BCD4";       //"#19D1FD";
      myBarChart.datasets[0].bars[i].fillColor = "#39B5B9";
      myBarChart.datasets[0].bars[i].strokeColor = "rgba(96, 125, 139, 0)";
      //myBarChart.datasets[0].bars[i].highlightFill = "#607D8B";
      myBarChart.datasets[0].bars[i].highlightFill = "#619CC4";
      myBarChart.datasets[0].bars[i].highlightStroke = "rgba(220,220,220,0)";
    }else{
      // Lime Green
      myBarChart.datasets[0].bars[i].fillColor = "#CDDC39";
      myBarChart.datasets[0].bars[i].strokeColor = "rgba(96, 125, 139, .0)";
      myBarChart.datasets[0].bars[i].highlightFill = "#619CC4";
      myBarChart.datasets[0].bars[i].highlightStroke = "rgba(220,220,220,0)";
    }
  }

  myBarChart.update();
}


// Provide your access token
L.mapbox.accessToken = 'pk.eyJ1IjoidGFyZWxsZWwiLCJhIjoiY2M2MWMwMzA1ZWZkYWMwOWI0NTU3NWZkMzk4NDdiNDgifQ.DcJ_Un9ugoHGeqAILvi6Dw';

// Create a map in the div #map
var map = L.mapbox.map('map', 'tarellel.eef55dd3')
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
          setCrime('liquor');
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
    setupChart(crimes);
  })
  .addTo(map);
