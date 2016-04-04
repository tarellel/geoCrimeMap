require 'open-uri'  # http://ruby-doc.org/stdlib-2.0.0/libdoc/open-uri/rdoc/OpenURI.html
require 'nokogiri'  # xpath - http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html
require 'json'      # https://github.com/flori/json
require 'csv'       # http://ruby-doc.org/stdlib-2.1.0/libdoc/csv/rdoc/CSV.html

# Used for cleaning up the returned data
def cleanup_address(address)
  rules = [
    {
      # Remove " Block " just use the specified address
      pattern: '[[:space:]](Block)[[:space:]]',
      replacement: ' '
    },
    {
      # Replace \sAv (where Ave is cut off at the end of the string)
      pattern: '\s(AV)$',
      replacement: ' Ave'
    },
    {
      # Replace mid sentence " AV " with " Ave " (aka: Avenue)
      pattern: '\s(AV)\s',
      replacement: ' Ave '
    }
  ]

  rules.each do |regex|
    address.gsub!(/#{regex[:pattern]}/i, regex[:replacement])
  end

  address
end

# Connects to mapbox API to get coordinates of the incident
def get_coords(address = '', token = '')
  # Change spaces to + to create a safe URLstring
  address = address.strip.gsub(/\s/, '+')

  # API-URL for fetching the addresses geo-location
  url = "https://api.tiles.mapbox.com/v4/geocode/mapbox.places/farmington,87401,#{address}.json?proximity=-108.20833683013916,36.73038906153143&access_token=#{token}"

  # Output address of where the crime occurred
  puts "Address: #{address}"

  # get URL Response
  response = open(url).read

  # Process response at JSON rather than plain text
  results = JSON.parse(response)

  coords = []
  if !results['features'][0].nil?
    coords[0] = results['features'][0]['geometry']['coordinates'][0]
    coords[1] = results['features'][0]['geometry']['coordinates'][1]
  else
    coords = [0, 0]
  end

  coords
end

# Attempt to remove the specified file
def remove_file(file)
  File.delete(file) if File.exist?(file)
end

# Get the reported crimes for the last 30 days
# => otherwise day to day the map appears pretty empty
report_start_date = Time.at(Time.now.to_i - (86400 * 30)).strftime('%Y-%m-%d')
today = Date.today.strftime('%Y-%m-%d')

# API token for geocoding
access_token = "<-- access_token -->"

# URL to scrape for the latest Police Department listed crimes
doc = Nokogiri.HTML(open('<!-- Crimes List URL -->'))

##### Begin evaluating the page response with Nokogiri
table = doc.at_xpath('//table')

crimes = []
crime = nil

# Skip procesing of headerRow column
# headerRow is the class they use instead of <thead> or <th>
table.xpath('tr[not(@class="headerRow")]').each do |tr|
  next if tr.content.empty?
  coords, address = ''

  td = tr.xpath('td')

  # clean up the Address string before trying to get its geo coordinates
  address = cleanup_address(td[2].text.strip)
  coords = get_coords(address, access_token)

  crime = {
    type: td[0].text.strip,
    happened_at: td[1].text.strip,
    address: address,
    case_id: td[3].text,
    desc: td[4].text.strip,
    long: coords[0].to_s,
    lat: coords[1].to_s
  }

  crimes << crime if crime
end

# Remove data/latest.csv for the newest pulled version
latest_data = 'assets/data/latest.csv'
remove_file(latest_data)

# convert hash to a csv string format
# case_id,happened_at,address,type,desc,lat,long
CSV.open(latest_data, 'wb',
         write_headers: true,
         headers: %w(case_id happened_at address type desc lat long)) do |csv|
  crimes.each do |crime|
    csv << [crime[:case_id],
            crime[:happened_at],
            crime[:address],
            crime[:type],
            crime[:desc],
            crime[:lat],
            crime[:long]
          ]
  end
end

# Remove existing file so overlaps do not cause file system errors
todays_crime_file = "assets/data/#{today}.csv"
remove_file(todays_crime_file)

# Preserve file for future data referencing
FileUtils.copy(latest_data, todays_crime_file)
