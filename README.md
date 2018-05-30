# Documentación y ejemplos de API para clientes

Todas las peticiones debe hacerce a la ruta base: https://api.monitorapp.io

En cada petición es obligatorio incluir en la cabecera el token de la empresa, es importante revisar la documentación del lenguaje de programación utilizado para saber cómo incluir el campo Authorization Token, al no incluirlo el servidor responderá con **HTTP Token: Access denied.**

## Uptimes
Para obtener los uptimes de las máquinas con sensor asignado se debe hacer una petición GET a la ruta **/uptimes/:date/:workstation_alias**.
En la ruta debe ir la fecha a consultar en formato * *yyyy-mm-dd* *  y opcionalmente el alias de la estación en caso de requerir los datos de una estación en específico.

La respuesta del servidor en caso de incluir el token de forma correcta es un json con la siguiente estructura:
```json
{
code: 0 si hubo algún error, 1 si la petición fue correcta.
message: En caso de code = 0 este campo indicará el mensaje ocurrido.
workstations: Arreglo con las estaciones, los campos de cada elemento se indican abajo.
}
```

El único valor que puede tener message es **WrongFormatDate** el cual ocurre al solicitar uptimes de una fecha con formato incorrecto, el formato debe ser * *yyyy-mm-dd* *, en el caso de proporcionar un alias incorrecto el sistema regresará workstations vacío.

Cada elemento de workstations es un json con los siguientes campos:
```json
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


client_token = ####Reemplaza por tu token
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
