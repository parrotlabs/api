require 'net/http'
require 'net/https'
require 'json'

# Parámetros de la petición
# Reemplaza por tu Token
client_token = 'XXXXXXXXXXXXXXXXXXXXXXXXXXX' 

# Arreglo que contiene los diferentes programas de producción a crear
production_plans = []

# Por cada programa nuevo repetir esta linea
# Con los datos de cada programa

# 1
production_plans << {planned_date: Date.today.to_s, workstation_alias: 'Asigna_tu_estacion', goal: 1, part_name: 'PRUEBA123'}
# 2
production_plans << {planned_date: Date.today.to_s, workstation_alias: 'Asigna_tu_estacion', goal: 1, part_name: 'PRUEBA1234'}
# 3
production_plans << {planned_date: Date.today.to_s, workstation_alias: 'Asigna_tu_estacion', goal: 1, part_name: 'PRUEBA12345'}

# Realizar peticiones
plan_index = 0
for plan in production_plans
	# Request
	uri = URI("https://api.monitorapp.io/production_plans")
	form_data = URI.encode_www_form(plan)
	request = Net::HTTP::Patch.new(uri)
	request.body = form_data
	request["AUTHORIZATION"] = "Token token=#{client_token}"
	http = Net::HTTP.new(uri.hostname, uri.port)
	http.use_ssl = true
	response = http.request(request)
	puts "\n\nRealizando petición #{plan_index+=1}"
	if response.code == '200'
		json = JSON.parse(response.body)
		puts json['code'] == 0 ? json['message'] : 'Programa creado.'
	else
		puts response.body
	end

	puts "petición #{plan_index} finalizada."
end