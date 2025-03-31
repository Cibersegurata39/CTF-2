# CTF-2
Capture the flag donde se trabaja la enumeración,

## Objetivo

Explicar la realización del _Capture the flag_ siguiente dentro del mundo educativo. Se preteneden conseguir dos archivos (_flags_), uno dentro del entorno del usuario básico y el otro en el entorno _root_. Para ellos, se deberá penetrar en la máquina, pasar al usuario básico y realizar una escalada de privilegios.

## Que hemos aprendido?

- Realizar fingerprinting y enumeración de puertos y enumeración web (en este caso utilizando una nueva herramienta llamada Dirsearch.
- 
- Escalada de privilegios.

## Herramientas utilizadas

- Kali Linux.
- Enumeración: Nmap, Dirsearch.
- Penetración: Metasploit. 

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

Con la misma herramienta busco posibles archivos cambiadno la lista por 'raft-large-files.txt'. En este caso solo ha encontrado el archivo ‘phpinfo.php’, el cual se puede acceder desde el navegador de Firefox. Dentro hay configuraciones que se pueden utilizar a nuestro favor, pero lo interesante es el uso del módulo *FPM/FastCGI* para manejar las solicitudes con el servidor web, lo cual me será de utilidad para el ataque.

### Vulnerabilidades explotadas

La versión del servidor *nginx* pertenece al año 2018, así que con la ayuda de **Metasploit** voy a investigar si existe algún exploit que pueda utilizar. Además, si me fijo en el 'phpinfo.php', la versión *php* utilizada es la 7.1.33. Buscando en NIST se encuentra una vulnerabilidad que afecta al *PHP-FPM* y que presenta esta versión de *php*, la cual provoca un *buffer underflow*, donde los datos se escriben fuera de los límites del búfer y sobrescribe áreas de memoria que se encuentran justo por debajo.

En *Metasploit* encuentro un módulo para arpovecahr la vulnerabilidad ‘exploit/multi/http/php_fpm_rce’. Al *exploit* en cuaestión se le debe indicar la dirección IP a atacar y el archivo que contiene el servidor, el cual es ‘phpinfo.php’ (encontrado en la enumeración web). El puerto de la máquina víctima ya está informado al 80 por defecto, pues es donde acostumbra a encontrarse el servicio *http*. De la misma manera, ya está informado la dirección IP de mi máquina y asigna el puerto 4444 para realizar la conexión.

<code>set rhosts 172.17.0.2</code>  
<code>set targeturi /phpinfo.php</code>  
<code>run</code>  

![image](https://github.com/user-attachments/assets/31d44957-372e-4457-9a50-df7e32cc044b)

El *exploit* nos permite acceder a la máquina e interactuar con ella mediante el *meterpreter*, para tener la *shell* más amigable y poder hacer uso de todos los comandos disponible, se introduce el comando *shell*. Lo siguiente es listar el contenido del directorio actual (/var/www/html) y aquí aparecen todos los directorios encontrados anteriormente por *Dirsearch*. Al dirigirnos a la carpeta ‘admin’, encontramos el archivo oculto ‘.flag.txt’. 

**Flag**: 58C250724441ED96979209921FAC3D89

![image](https://github.com/user-attachments/assets/d7349ff0-4d1b-403f-abc9-b5c17a291205)

Ahora es necesario escalar privilegios para encontrar la segunda bandera. Para ello, me dirijo a la otra carpeta sospechosa que ya había encontrado en la enumeración web: ‘notes’. Dentro de esta encuentro el archivo ‘notes.txt’, el cual contiene únicamente los números 1, 3 y 11. Así que me dispongo a revisar las carpetas con los mismos nombres que se encontraban en '/var/www/html'. Dentro de cada una de las tres carpetas encuentro tres archivos llamados ‘junk.txt’. El contenido de los dos primeros archivos esta codificado en *base64*, mientras que el tercero lo está en *hexadecimal*. Para la decodificación se pueden utilzar mútiples páginas web, de tal manera que obtengo lo siguiente:

| Carpeta | Contenido            | Codificación | Contenido decodificado |
|---------|----------------------|--------------|------------------------|
|    1    | MTIzNF9zZWM=         | Base64       | 1234_sec               |
|    3    | aG9vcmEh             | Base64       | hoora!                 |
|    11   | 63616c69666f726e6961 | Hexadecimal  | hoora!                 |
