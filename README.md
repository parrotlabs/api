# api
Documentación y ejemplos de API para clientes

Todas las peticiones debe hacerce a la ruta base: https://api.monitorapp.io

En cada petición es obligatorio incluir en la cabecera el token de la empresa, es importante revisar la documentación del lenguaje de programación utilizado para saber cómo incluir el campo Authorization Token, al no incluirlo el servidor responderá con HTTP Token: Access denied.

Uptimes
Para obtener los uptimes de las máquinas con sensor asignado se debe hacer una petición GET a la ruta /uptimes/:date/:workstation_alias.
En la ruta debe ir la fecha a consultar en formato yyyy-mm-dd y opcionalmente el alias de la estación en caso de requerir los datos de una estación en específico.
La respuesta del servidor en caso de incluir el token de forma correcta es un json con la siguiente estructura:
{
code: 0 si hubo algún error, 1 si la petición fue correcta.
message: En caso de code = 0 este campo indicará el mensaje ocurrido.
workstations: Arreglo con las estaciones, los campos de cada elemento se indican abajo.
}

El único valor que puede tener message es WrongFormatDate el cual ocurre al solicitar uptimes de una fecha con formato incorrecto, el formato debe ser yyyy-mm-dd, en el caso de proporcionar un alias incorrecto el sistema regresará workstations vacío.

Cada elemento de workstations es un json con los siguientes campos:
{
id: id de la estación
name: Nombre de la estación
uptimes: Arreglo con todos los uptimes, cada elemento en formato [{event_time, event_type}]
}
