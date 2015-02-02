require 'rest-client'
require 'json'
require 'launchy'

client_id = 'ENTER YOUR APP ID HERE'
client_secret = 'ENTER YOUR APP SECRET HERE'

host_base = 'ENTER YOUR URL HERE'

response = RestClient.post "#{host_base}/api/oauth2/token", {
    grant_type: 'client_credentials',
    client_id: client_id,
    client_secret: client_secret
}, :accept => :json

access_token = JSON.parse(response)['access_token']
response = RestClient.post(
  "#{host_base}/api/v1/documents",
  {:document_type => "A", :acquisition_title => "Title1", :document_number => 1233, :document_date => "2014-06-05"}.to_json,
  :content_type => :json, :accept => :json, :Authorization => "Bearer #{access_token}"
)

response_json = JSON.parse(response)
document_id = response_json['document']['id']

puts "Document ID is: #{document_id}"

response = RestClient.post(
  "#{host_base}/api/v1/interviews",
  {:document_id => document_id}.to_json,
  :content_type => :json, :accept => :json, :Authorization => "Bearer #{access_token}"
)

puts "Testing getting document at #{host_base}/api/v1/documents/#{document_id}?format=json"
response1 = RestClient.get(
  "#{host_base}/api/v1/documents/#{document_id}?format=json",
   :Authorization => "Bearer #{access_token}"
)
File.open('resttest.json', 'w'){|f| f << response1.to_str}

puts "Testing getting document at #{host_base}/api/v1/documents/#{document_id}?format=pdf"
response2 = RestClient.get(
  "#{host_base}/api/v1/documents/#{document_id}?format=pdf",
   :Authorization => "Bearer #{access_token}"
)
File.open('resttest.pdf', 'w'){|f| f << response2.to_str}

puts "Testing getting document at #{host_base}/api/v1/documents/#{document_id}?format=xml"
response3 = RestClient.get(
  "#{host_base}/api/v1/documents/#{document_id}?format=xml",
   :Authorization => "Bearer #{access_token}"
)
File.open('resttest.xml', 'w'){|f| f << response3.to_str}

puts "Testing getting document at #{host_base}/api/v1/documents/#{document_id}?format=docx"
response4 = RestClient.get(
  "#{host_base}/api/v1/documents/#{document_id}?format=docx",
   :Authorization => "Bearer #{access_token}"
)
File.open('resttest.docx', 'w'){|f| f << response4.to_str}


puts "Interviews POST response: #{response}"

interview_id = JSON.parse(response)['interview_launcher']['id']

puts "Getting launch url at #{host_base}/api/v1/interviews/#{interview_id}/launch_url"
response = RestClient.get(
  "#{host_base}/api/v1/interviews/#{interview_id}/launch_url",
  :content_type => :json, :accept => :json, :Authorization => "Bearer #{access_token}"
)

puts "URL to use is #{JSON.parse(response)['launch_url']}"
Launchy.open("#{JSON.parse(response)['launch_url']}")

