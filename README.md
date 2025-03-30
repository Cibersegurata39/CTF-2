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
- Enumeración: nmap, .
- Penetración: . 

## Steps

### Enumeración y fingerprinting

La máquina a vulnerar está desplegada dentro de un Docker, para encontrar este, desde el terminal de Kali, se busca su direción IP con el comando <code>ipconfig</code>. En la respuesta se averigua que su dirección IP es la 172.17.0.1, por lo que la máquina víctima debe estar en la red 172.17.0.X. Utilizando la herramienta __nmap__ puedo hacer un barrido para encontrar el host que estoy buscando, para hacerlo más rápido no compruebo puertos. Una vez la máquina ha sido localizada, con la ayuda de __nmap__ se buscan los puertos de la máquina que se encuentran abiertos y las versiones que corren en ellos.  (Para cualquier duda, consultar el repositorio CTF-1). 


### Vulnerabilidades explotadas

