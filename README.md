# Documentación y ejemplos de API para clientes

Todas las peticiones debe hacerce a la ruta base: https://api.monitorapp.io

En cada petición es obligatorio incluir en la cabecera el token de la empresa, es importante revisar la documentación del lenguaje de programación utilizado para saber cómo incluir el campo **Authorization Token**, al no incluirlo el servidor responderá con **HTTP Token: Access denied.**





## Uptimes

### URL
Método: **GET**  
URL: https://api.monitorapp.io/uptimes/:date/:workstation_alias  
Ejemplo todas las estaciones:  https://api.monitorapp.io/uptimes/2018-06-06/   
Ejemplo una estación:  https://api.monitorapp.io/uptimes/2018-06-06/armadora

### Descripción
Para obtener los uptimes de las máquinas con sensor asignado se debe hacer una petición GET a la ruta **https://api.monitorapp.io/uptimes/:date/:workstation_alias**.
En la ruta debe ir la fecha a consultar en formato * *yyyy-mm-dd* *  y opcionalmente el alias de la estación para limitar los resultados a una sola estación.

La respuesta del servidor en caso de incluir el token de forma correcta es un json con la siguiente estructura:
```
{
code: 0 si hubo algún error, 1 si la petición fue correcta.
message: En caso de code == 0 este campo indicará el mensaje del error ocurrido.
workstations: Arreglo de estaciones, los campos de cada elemento se indican abajo.
}
```

El único valor que puede tener message es **WrongFormatDate** el cual ocurre al solicitar uptimes de una fecha con formato incorrecto, el formato debe ser * *yyyy-mm-dd* *, en el caso de proporcionar un alias incorrecto el sistema no regresa error, simplemente regresará workstations vacío.

Cada elemento de workstations es un json con los siguientes campos:
```
{
id: id de la estación
name: Nombre de la estación
uptimes: Arreglo con todos los uptimes, cada elemento en formato [{event_time, event_type}]
}
```

### Ejemplo Ruby
Crear un archivo uptime.rb y pega el siguiente contenido dentro del archivo
```ruby
require 'net/http'
require 'net/https'
require 'json'


client_token = ####Tu token aquí
# Fecha a consultar
event_date = ARGV[0]

if !event_date.blank?
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
else
	puts "Debes indicar la fecha en formato yyyy-mm-dd."
end
``` 
> Es importante reemplazar **client_token** por el token referente a su empresa

Para ejecutar el script en la terminal o consola escribir: `ruby uptime.rb 2018-05-30`

> El único argumento que recibe el script es la fecha a consultar, es importante indicar una fecha de lo contrario se mostrará un mensaje de error.





## Programa de producción

### URL
Método: **PATCH**  
URL: https://api.monitorapp.io/production_plans/

### Descripción
Este servicio se encarga principalmente de generar los programas de producción de la fecha indicada, aunque en caso de indicar un nombre de parte que no exista también se encarga de crearla en la misma petición.

Los parámetros que recibe el servicio son los siguientes:
```
planned_date.- Fecha a programar la producción, debe tener el formato yyyy-mm-dd.
workstation_alias.- Alias de la estación donde se generará la producción.
goal: meta a programar.
part_name.- Nombre de la parte a programar, si no existe será creada.
part_code.- Si la parte no existe en sistema debe indicarse un código (único), es un campo opcional si no se indica se toma por defecto el mismo nombre de la parte.  

part_traceability_code.- Aplica lo mismo que part_code.
batch_size.- Tamaño del bache producido, es un campo opcional, su valor por defecto es 1 y si la parte ya existe no es modificado.
utility.- Valor de equivalencia de la parte en la estación, es un campo opcional, su valor por defecto es 1.
```
> La respuesta del servidor sólo incluye dos campos {code: 0 = fallo/1 = ok, message: Error ocurrido en caso de code=0}

### Ejemplo Ruby
Crear un archivo production_plan.rb y pega el siguiente contenido dentro del archivo
```ruby
require 'net/http'
require 'net/https'
require 'json'

# Parámetros OBLIGATORIOS
client_token = ####Tu token aquí
planned_date = ####Fecha a programar el plan
workstation_alias = ####Alías de la estación, debe coincidir con el sistema Monitor
production_goal = ####Piezas a producir
part_name = #### Nombre de la pieza a producir, debe coincidir con el sistema Monitor

# Se pueden agregar los demás campos opcionales en request_body
request_body = {planned_date: planned_date, workstation_alias: workstation_alias, goal: production_goal, part_name: part_name }  

# Request
uri = URI("https://api.monitorapp.io/production_plans")
form_data = URI.encode_www_form(request_body)
request = Net::HTTP::Patch.new(uri)
request.body = form_data
request["AUTHORIZATION"] = "Token token=#{client_token}"

http = Net::HTTP.new(uri.hostname, uri.port)
http.use_ssl = true
response = http.request(request)

if response.code == '200'
	json = JSON.parse(response.body)
	puts json['code'] == 0 ? json['message'] : 'Petición finalizada'
else
	puts response.body
end
```

Para ejecutar el script en la terminal o consola escribir: ruby production_plan.rb

Posibles errores:
```
**WrongFormatDate**.- La fecha a programar tiene un formato incorrecto, debe ser yyyy-mm-dd.
**WorkstationAliasNotFound**.- El alias de la estación no existe en el sistema Monitor.
**InvalidUtility**.- El valor de utilidad debe ser mayor a 1.
**InvalidGoal**.- El valor de la meta debe ser mayor a 1.
**InvalidBatch**.- El valor del bache debe ser mayor a 1.
**PartCanNotBeCreated**.- Posiblemente el código o código de trazabilidad ya existe en sistema.
``` 






## Partes

### URL
Método: **POST**  
URL: https://api.monitorapp.io/parts/

### Descripción
Este servicio se encarga crear partes y asignarlas a una estación.

Los parámetros que recibe el servicio son los siguientes:
```
{
name.- Nombre único de la parte.
code.- código/folio único de la parte, si no se indica toma el mismo valor que name.
traceability_code: código de trazabilidad, si no se indica toma el mismo valor que name.
price.- Precio de la parte, si no se indica el valor por defecto es 0.
workstations.- Arreglo con la estructura especificada en la parte de abajo por acada estación.  
}
``` 
Cada estación debe tener el formato:
```
{
alias.- Alias de la estación, es un dato obligatorio.
batch_size.- Tamaño del bache dentro del rango 0-10000, si no se indica batch_size el valor por defecto queda en 1.
utility: Valor de utilidad dentro del rango 0-1, si no se indica utility el valor por defecto queda en 1.
}
``` 
> La respuesta del servidor sólo incluye dos campos {code: 0 = fallo/1 = ok, message: Error ocurrido en caso de code=0}

### Ejemplo Ruby
Crear un archivo parts.rb y pega el siguiente contenido dentro del archivo
```ruby
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
parts << { part: {name: 'Modelo a', code: 'code_modelo_a', traceability_code: 'tacea', price: 100, workstations: [{alias: 'Maquina de Cafe', batch_size: 10}] } }
# 2
parts << { part: {name: 'Modelo b', code: 'code_modelo_b', traceability_code: 'taceb' } }
# 3
parts << { part: {name: 'Modelo c', code: 'code_modelo_c', traceability_code: 'tacec', workstations: [{alias: 'Maquina de Cafe', utility: 0.5}] } }

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
```

Para ejecutar el script en la terminal o consola escribir: ruby production_plan.rb

Posibles errores:
```
**WorkstationAliasNotFound**.- El alias de la estación no existe en el sistema Monitor.
**Name has already been taken**.- El nombre no puede estar duplicado.
**Code has already been taken**.- El código no puede estar duplicado.
**Traceability code has already been taken**.- El código de trazabilidad no puede estar duplicado.
**Batch size is not included in the list**.- El bache está fuera del rango 0-10000.
**Utility is not included in the list**.- La utilidad está fuera del rango 0-1.
``` 
