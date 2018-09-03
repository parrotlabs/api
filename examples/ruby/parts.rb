require 'net/http'
require 'net/https'
require 'json'

# Parámetros de la petición
# Reemplaza por tu Token
client_token = 'XXXXXXXXXXXXXXXXXXXXXXXXXXX' 

# Arreglo que contiene las partes a crear
parts = []

# Por cada parte nueva repetir esta linea

# 1
parts << { part: {name: 'Modelo a', code: 'code_modelo_a', traceability_code: 'tacea', price: 100, workstations: ['Maquina de Cafe'] } }
# 2
parts << { part: {name: 'Modelo b', code: 'code_modelo_b', traceability_code: 'taceb' } }
# 3
parts << { part: {name: 'Modelo c', code: 'code_modelo_c', traceability_code: 'tacec', workstations: ['Maquina de Cafe'] } }

# Realizar peticiones
part_index = 0
for part in parts
	# Request
	uri = URI("https://api.monitorapp.io/parts")
	form_data = URI.encode_www_form(part)
	request = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
	request.body = part.to_json
	request["AUTHORIZATION"] = "Token token=#{client_token}"
	http = Net::HTTP.new(uri.hostname, uri.port)
	http.use_ssl = true
	response = http.request(request)

	puts "\n\nRealizando petición #{part_index+=1}"
	if response.code == '200'
		json = JSON.parse(response.body)
		puts json['code'] == 0 ? json['messages'] : 'Parte creada.'
	else
		puts response.body
	end

	puts "petición #{part_index} finalizada."
end