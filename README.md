# CTF-2
Capture the flag donde se trabaja la enumeración,

## Objetivo

Explicar la realización del _Capture the flag_ siguiente dentro del mundo educativo. Se preteneden conseguir dos archivos (_flags_), uno dentro del entorno del usuario básico y el otro en el entorno _root_. Para ellos, se deberá penetrar en la máquina, pasar al usuario básico y realizar una escalada de privilegios.

## Que hemos aprendido?

- Realizar fingerprinting y enumeración de puertos y enumeración web.
- 
- Escalada de privilegios.

## Herramientas utilizadas

- Kali Linux.
- Enumeración: nmap, dirsearch.
- Penetración: . 

## Steps

### Enumeración y fingerprinting

La máquina a vulnerar está desplegada dentro de un Docker, para encontrar este, desde el terminal de Kali, se busca su direción IP con el comando <code>ipconfig</code>. En la respuesta se averigua que su dirección IP es la 172.17.0.1, por lo que la máquina víctima debe estar en la red 172.17.0.X. Utilizando la herramienta __nmap__ puedo hacer un barrido para encontrar el host que estoy buscando, para hacerlo más rápido no compruebo puertos. Una vez la máquina ha sido localizada, con la ayuda de __nmap__ se buscan los puertos de la máquina que se encuentran abiertos y las versiones que corren en ellos.  (Para cualquier duda, consultar el repositorio CTF-1). 

![image](https://github.com/user-attachments/assets/4b080fd4-a104-4a4d-9a5a-ef875897d24c)

El comando devuelve 2 puertos TCPs abiertos:  
- En el puerto 22 corre la versión Openssh 7.6p1, en un sistema Ubuntu, del servicio SSH.  
- En el puerto 80 corre el servidor Nginx 1.14.0, en un sistema Ubuntu, en el servicio HTTP.

Además, el script por defecto de nmap informa que el acceso a la web está restringido, mostrando un mensaje ‘403 forbidden’. Lo cual compruebo desde el navegador de Firefox.

![image](https://github.com/user-attachments/assets/068245d0-0496-4f46-9e30-789e82bb4485)

Seguidamente, enumero los directorios y archivos alojados en el servidor. En este caso utilizo dirsearch para ambos propósitos con la ayuda de python3 e indicando la dirección de la herramienta. Con la opción ‘-u’ indico la URL a enumerar y con ‘-w’ la lista utilizada con los directorios a buscar.

<code>python3 /usr/lib/python3/dist-packages/dirsearch/dirsearch.py -u 172.17.0.2 -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt</code>

**Dirsearch** devuelve una serie de directorios, pero todos ellos redireccionados a otros directorios con el mismo nombre y con un ‘/’ añadido al final. De entre todos los directorios destaca uno llamado ‘notes’ y otro ‘admin’, los cuales se deberán investigar más adelante. Todos estos directorios, de nuevo, no son alcanzables, mostrándose el mensaje 403.

![image](https://github.com/user-attachments/assets/56b29f77-5796-4371-8c6b-82ec6db98110)

Con la misma herramienta busco posibles archivos cambiadno la lista por 'raft-large-files.txt'. En este caso solo ha encontrado el archivo ‘phpinfo.php’, el cual se puede acceder desde el navegador de Firefox. Dentro hay configuraciones que se pueden utilizar a nuestro favor, pero lo interesante es el uso del módulo FPM/FastCGI para manejar las solicitudes con el servidor web, lo cual me será de utilidad para el ataque.

### Vulnerabilidades explotadas

