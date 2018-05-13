# QoS Script 

Script para transformar Ubuntu Server en un servidor QoS transparente.

## Empezando

El objetivo es configurar fácilmente un servidor que evite la saturación del ancho de banda de Internet, priorice determinados tipos de tráficos, y cachee en lo posible el tráfico de Internet.

Puedes ver la idea de lo que se quiere configurar en el siguiente [video](https://www.youtube.com/watch?v=_rujwjzTPmc).

### Prerequisitos

* Hardware: necesitaras un servidor con al menos 2 tarjetas de red.

* Software: Probado únicamente con Ubuntu Server 16.04, pero puede que funcione con otras versiones de Ubuntu.

### Instalación

Descárgate el repositorio en tu servidor:

```
git clone https://github.com/Canx/qos.git
```

Ejecuta el script 'config.sh':

```
./config.sh
```

Contesta a las diferentes preguntas (interfaces LAN/WAN, Ip de administración, etc...).

Puedes verificar que el archivo qos.cfg contiene la información correcta antes de continuar la instalación. En caso de cometer un fallo aquí ojo que puedes dejar el servidor no accesible desde el exterior!

Por último ejecuta el script 'install' como root:

```
sudo ./install.sh
```

Si todo ha ido correctamente puedes verificar que funciona conectando el servidor entre el router y la red local, mediante los interfaces LAN y WAN definidos anteriormente.

Comprueba además que puedes acceder al interfaz de netdata en http://IP:19999

## Construido con

* [firehol](https://github.com/firehol/firehol) - Firewall y gestión QoS 
* [netdata](https://github.com/firehol/netdata) - Monitorización en tiempo real
* [squid](http://www.squid-cache.org/) - Cache HTTP
* [bind](https://www.isc.org/downloads/bind/) - Cache DNS

## Contribuciones

Todos los 'issues' y 'pull requests' son bienvenidos!

## Autores

* **Ruben Cancho** - *trabajo inicial* - [Canx](https://twitter.com/Canx)

Mira la lista de [colaboradores](https://github.com/Canx/qos/graphs/contributors) que han participado en este proyecto.

## Reconocimientos

* Gracias a mis compañeros del IES Henri Matisse por el apoyo y la ayuda recibida!
