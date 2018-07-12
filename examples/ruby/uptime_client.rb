require 'net/http'
require 'net/https'
require 'json'

# Reemplaza por tu Token
client_token = 'XXXXXXXXXXXXXXXXXXXXXXXXXXX'
# Fecha a consultar
event_date = Date.today.to_s
# Petición
uri = URI("https://api.monitorapp.io/uptimes/#{event_date}")
request = Net::HTTP::Get.new(uri)
request["AUTHORIZATION"] = "Token token=#{client_token}"
http = Net::HTTP.new(uri.hostname, uri.port)
http.use_ssl = true
response = http.request(request)

if response.code == '200'
	json = JSON.parse(response.body)
	puts json['code'] == 0 ? json['message'] : json['workstations']
else
	puts response.body
end