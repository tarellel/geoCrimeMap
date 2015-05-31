require 'open-uri'  # http://ruby-doc.org/stdlib-2.0.0/libdoc/open-uri/rdoc/OpenURI.html
require 'nokogiri'  # xpath - http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html
require 'json'      # https://github.com/flori/json
require 'csv'       # http://ruby-doc.org/stdlib-2.1.0/libdoc/csv/rdoc/CSV.html
require 'pp'

# Used for cleaning up the specified address
def cleanse_address(address)
  rules = [
    {
      # Remove " Block " from when it says something similar to "1400 Block N Dustin Ave" and just use the specified address
      #pattern: '\s(Block)\s',
      pattern: '[[:space:]](Block)[[:space:]]',
      replacement: " "
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

  return address
end


# Connects to mapbox API to get coordinates of in incident
def get_coords(address='', token='')
  # Change spaces to + to create a safe URL
  address = address.strip.gsub(/\s/,'+')

  url = "https://api.tiles.mapbox.com/v4/geocode/mapbox.places/farmington,87401,#{address}.json?proximity=-108.177391,36.743732&access_token=#{token}"

  # ============================================================
  # Output address of where the crime occurred
  # ============================================================
  puts "Address: #{address}"

  # get URL Response
  response = open(url).read

  # Process response at JSON rather than plain text
  results = JSON.parse(response)
  #pp results # output response an formatted JSON

  coords = []
  if !results['features'][0].nil?
    coords[0] = results['features'][0]['geometry']['coordinates'][0]
    coords[1] = results['features'][0]['geometry']['coordinates'][1]
  else
    coords = [0,0]
  end

  return coords
end

# Attempt to remove the specified file
def removeFile(file)
  if File.exists?(file)
    File.delete(file)
  end
end


dateFormat = "%Y-%m-%d"#
# Get the reported crimes for the last 12 days
# => otherwise day to day the map appears pretty empty
daysAgo = Time.at(Time.now.to_i - (86400 * 12)).strftime("%Y-%m-%d")
today = Date.today.strftime("%Y-%m-%d")

# API token for geocoding
access_token = 'pk.eyJ1IjoidGFyZWxsZWwiLCJhIjoiY2M2MWMwMzA1ZWZkYWMwOWI0NTU3NWZkMzk4NDdiNDgifQ.DcJ_Un9ugoHGeqAILvi6Dw'


# URL to scrape for crime reports
doc = Nokogiri.HTML(open("https://www.crimereports.com/services/crimedata/crime_list.html/#{daysAgo}/#{today}/149,150,104,180,179,178,100,98,103,101,99,163,168,166/36.78386146/36.68591063/-108.3066628/-108.11302876/0/false?limit=false"))



##### Begin evaluating the page response with Nokogiri
table = doc.at_xpath('//table')

crimes = []
crime = nil

# Skip procesing of headerRow column
# headerRow is the class they use instead of <thead> or <th>
table.xpath('tr[not(@class="headerRow")]').each do |tr|
  next if tr.content.empty?
  coords = nil
  address = ''

  td =  tr.xpath('td')

  # clean up the Address string before trying to get its geo coordinates
  #td[2] =
  address = cleanse_address(td[2].text.strip)
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
  crime = ''

end


latestData = ("assets/data/latest.csv")
removeFile(latestData)

# convert hash to a csv string format
# case_id,happened_at,address,type,desc,lat,long
CSV.open(latestData,"wb", write_headers: true, headers: ['case_id','happened_at','address','type','desc','lat','long']) do |csv|
  crimes.each do |crime|
    csv << [crime[:case_id], crime[:happened_at], crime[:address], crime[:type], crime[:desc], crime[:lat], crime[:long]]
  end
end

# Remove existing file so overlaps do not cause file system errors
crimeFile = ("assets/data/#{today}.csv")
removeFile(crimeFile)
# Preserve file for future data referencing
FileUtils.copy(latestData, crimeFile)
