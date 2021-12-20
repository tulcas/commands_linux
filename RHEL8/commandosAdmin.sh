


# COMANDOS de RED
# #######################################################################################################################################
ss -ta | grep ssh
netstat
ip a s

# muestra el trafico de una tarjeta de red

 ip -s -h link show enp1s0


# muestra tarjetas de red instaladas
nmcli dev show


# muestra todos los puertos
less /etc/services

# Muesta discos instalados
fdisk -l

# nmcli
nmcli connection show --active 

man nmcli-examples

#add device
nmcli connection add con-name secundaria type ethernet ifname enp7s0
nmcli device status
nmcli connection show secundaria 

# asignarle IP gateway y DNS 
nmcli device disconnect enp7s0
nmcli connection modify secundaria ip4 192.168.20.111/24 gw4 192.168.20.1 ipv4.dns 192.168.20.80
nmcli connection modify secundaria +ipv4.dns 1.1.1.1
nmcli connection show secundaria  | grep ipv4.dns
mcli connection modify secundaria connection.autoconnect yes
nmcli con up secundaria


nmcli connection show
nmcli connection show --active
nmcli device status

nmcli connection down enp7s0 ; nmcli connection up enp7s0 

nmcli device connect enp7s0 #activar interface despues de crear archivo de config



# tracepath

tracepath www.google.com


# COMANDOS de RED
# #######################################################################################################################################


# YUM 
# #######################################################################################################################################
yum list httpd
yum provides netstat
yum module list
yum module list postgresql
yum module install postgresql
yum module remove postgresql:9.6
yum module list --installed
yum install @python36
yum search all "web server"
yum search httpd


# YUM 
# #######################################################################################################################################

# systemctl 
# #######################################################################################################################################

systemctl is-active sshd
systemctl is-enabled sshd
systemctl is-failed sshd
systemctl --failed  -t service
systemctl --failed  -t service --all
systemctl cat sshd.service
systemctl list-units  -t socket  --all
systemctl list-unit-files
systemctl status chronyd.service
ps aux | grep 2654
systemctl list-units  -t socket  --all
systemctl list-unit-files
systemctl list-unit-files -t socket
systemctl list-unit-files -t path
systemctl list-unit-files -t path  -all
systemctl list-dependencies httpd
systemctl reload dnsmasq.service (recargar configuracion de un service)
systemctl restart dnsmasq.service
systemctl list-dependencies --after cron

####
systemctl enable --now autofs.service (habilita y arranca el service)



# #######################################################################################################################################
Gestion de DISCOS/Almacenamiento basico

lsblk (Muestra el estado de las particiones)
lsblk -fp (mas info del filesystem)
cat /proc/partitions (otra opcion para ver los discos)

####################
## PARTED ###
####################
parted /dev/vdb print (muestra el estado de la particion, si muestra "Partition Table: unknown" esta sin formato)
parted /dev/vdc mklabel gpt (habilita particion para que sea del tipo gpt)
parted /dev/vdc mklabel msdos (habilita particion para que sea del tipo msdos)

udevadm settle  (ejecutar siempre despues de terminar con parted) (Use the following command to wait for the system to register the new device node:)

parted /dev/vdb mkpart primary ext4 200MB 400MB (Otra forma de usar parted)

#########################################################################################################

####################
## fdisk ###
####################


#########################################################################################################
fdisk -l /dev/vdb
fdisk /dev/vdb
lsblk -fp
gdisk /dev/vdc (Particiones GPT)
udevadm settle  (ejecutar siempre despues de terminar con parted) (Use the following command to wait for the system to register the new device node:)

lsblk -fp


**** Particiones GPT *****
gdisk /dev/vdb 


#########################################################################################################
**** Particiones SWAP *****
#########################################################################################################
lsblk -fp

fdisk /dev/vdb3 #(crear particion del tipo swap)
mkswap /dev/vdb3 #(dar formato swap)
udevadm settle #(actualizar cambios en discos)
lsblk -fp #(verificar particiones creadas)
echo "UUID=6fe7eef4-1cc5-4468-b148-65db60fa9bad  swap swap defaults 0 0" >> /etc/fstab (montar particion swap en fstab)
systemctl daemon-reload #(recargar cambios en discos y fstab)
swapon /dev/vdb3 #(habilitar swap)
free -h #(verificar swap activada)
#########################################################################################################


#########################################################################################################
**** LVM *****
#########################################################################################################
echo "/dev/mapper/vg_data-lv_logico_data1 /mnt/lv_logico_data1 xfs defaults 0 0" >> /etc/fstab

udevadm settle (actualiza particiones )
partprobe -s (actualiza particiones )



lvextend /dev/vg_data/lv_logico_data1 -L +80M -r -t (extender particion con 80 MB) (-t para probar cambios antes)


#########################################################################################################
**** LOGS *****
########################################################################################################


# Monitoreo de logs en tiempo real -f
tail -f /var/log/secure
semanage fcontext -a -t httpd_sys_content_t 'web1(/.*)?' (para que funcione apache SELInux)
restorecon -Rvv /web1/ (para que funcione apache SELInux)



#########################################################################################################
**** SElinux *****
#########################################################################################################


semanage fcontext -l | grep "var\/www\/html"

ls -lZ
ps aZx | head
getenforce (consultar es estado de SElinux)

setenforce (cambiar el modo)

cat /etc/selinux/config (archivo de configuracion de SElinux)

sed -i -e "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config (busca y cambia una linea dentro de selinux/config  )

who -r (en que runlevel esta corriendo el SO)

**** boolean politicas de SElinux *****

semanage boolean -l | head

setsebool -P abrt_anon_write on (produce cambio permanete)
setsebool  abrt_anon_write on (produce cambio temporal, se reestablece al reinciar)


#########################################################################################################
**** firewall (seguridad )*****
#########################################################################################################

firewall-cmd --list-all-zones
firewall-cmd --list-all-zones
firewall-cmd --get-default-zone

firewall-cmd  --set-default-zone=work 
firewall-cmd --list-all

**** Habilitar puerto http/https *****

echo "Hola LAB_01 - firewalld" >> /var/www/html/index.html

systemctl enable --now httpd
systemctl status httpd
systemctl mask  nftables.service (enmascarar servicio siempre)

firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

**** Habilitar puerto en SElinux par que funcione en firewall-cmd*****
semanage port -l | grep http
semanage port -a -t http_port_t -p tcp 10 (Habilitar en SElinux)
firewall-cmd --permanent --add-port=1009/tcp (Habilitar en firewall)
firewall-cmd --reload 
systemctl restart httpd


#########################################################################################################
**** Usuarios y permisos *****
#########################################################################################################


date -d "+8 days" +"%Y-%m-%d" # Cacular dias en el futuro

id userone
getent user userone
getent passwd userone
useradd lab2
usermod -c "User Lab2 comentario" lab2
tail /etc/passwd
useradd lab4 -c "User Lab4 comentario" -u 2121
groupadd ABC
groupadd -g 2155 ABCD
groupmod -n abcNEW ABC
groupmod -g 2323 abcNEW 
getent group admins
getent group developers
groupmems -lg developers

chage -m 2 -M 90 -W 6 -I 4 -E 2019-12-15 admin1

date -d "+8 days" +"%Y-%m-%d" # Cacular dias en el futuro

for i in dev3 dev2 admin3; do echo "passwd" | passwd $i --stdin; done #cambia passwd mutiple users


#########################################################################################################
**** 14 - Gestion de Permisos Sobre Archivos*****
#########################################################################################################

ls -ld #muestra pemisos de carpeta
chmod u-w C3/ #quita permisos de escritura
chmod u+w C3/ #suma permisos de escritura

chmod u=rwx,g=rwx,o=rwx C3/ #cambio de permisos a usuarios grupos y others #suma de permisos
chmod u-w,g-x,o-rwx C3/ #cambio de permisos a usuarios grupos y others #resta de permisos
chmod a-x C3/ #cambio de permisos a todos ALL #se quita ejecucion a todos
chmod a-w C3/  #cambio de permisos a todos ALL #se quita escritura a todos

chmod -R o+X LAB11/ #cambiar los permisos recursivamente a todas las carpetas pero NO a los archivos dentro


*******************************************************
Sticky bit
*******************************************************



chmod 3770 contabilidad/ # sticky bit numerico
chmod u=rwx,g=srwx,o=t--- servicios/ # sticky bit modal
*******************************************************
*******************************************************

#########################################################################################################
**** 16 Ajuste del rendimiento del sistema ****
#########################################################################################################

ps aux | grep userone

kill -l

#userone     2221  0.0  0.6  25688  5516 pts/1    S+   00:29   0:00 -bash

kill 2221

kill -9 2221 #obliga a morir el proceso

bg # envia el proceso al background para que sigue ejecutandose

jobs #muestra los procesos/comandos ejecutandose

ps aux | grep userone # muestra todos los procesos que ejecuto el usuario: userone

pkill tail #mata todos los procesos de tail corriendo

pkill -U userone #mata todos los procesos y la sesion del usuario userone

kill -l  #muestra listado de senales para enviar a kill 

kill -SIGTERM %1 #ejecuta segun la senial enviada en %

yum list installed tuned #verifica si esta instalado tuned

systemctl status tuned.service #muesta estado del servicio

systemctl status -l tuned  #muesta estado del servicio

tuned-adm  active #muestra que profiles tiene activo

tuned-adm  list #muestra todos los profiles que se pueden activar

tuned-adm  recommend #muestra el profile recomendado automaticamente

tuned-adm profile virtual-guest #cambia de profile en este caso se aplica virtual-guest

tuned-adm  off #apaga el servicio tuned

uptime #tiempo ejecucion del servidor

lscpu #informacion del CPU


for i in $(seq 1 3); do sha1sum /dev/zero & done #crea 3 procesos sha1sum y lo envia al bg

ps -o pid,pcpu,nice,comm $(pgrep sha1sum) #muestra los procesos con filtros de la variable $(pgrep sha1sum)

sudo renice -n -5 15308 #cambia el nice al proceso 15308

watch -d 'ps -o pid,pcpu,nice,comm $(pgrep sha1sum)' #monitorea en tiempo real el cambio de asignacion de CPU del proceso sha1sum 


#########################################################################################################
**** 17 - Acceso a sistemas ****
#########################################################################################################

ssh-keygen #genera key publica y privada
ssh-keygen -f .ssh/new_pass  #genera key publica y privada en directorio especifico new_pass

** compartir clve publica **
ssh-copy-id root@rocky8master #copia la clave publica (como usuario root) del servidor rocky8master
ssh rocky8master #conecta al server sin pedir passwd



#########################################################################################################
**** 18 - Programaciond de Tareas Futuras  ****
#########################################################################################################

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed





:r! cat /etc/crontab #en VIM te trae la leyenda

00 03 * * mon /usr/bin/dnf -y update
00 05 * * mon /usr/sbin/reboot 

*/1 00-08 * * mon-fri /usr/bin/date  >> /home/userone/cron_date.txt #“At every minute past every hour from 0 through 8 on every day-of-week from Monday through Friday.”
fedores7x



TTTHHHWWWXXX%%%$$$###
TTTHHHWWWXXX%%%$$$###
































git commit -a -m "17 - Acceso a sistemas - Terminada" | git push


http://tracking.payoneer.com/aff_c?offer_id=399&aff_id=42435&url_id=1047

https://payouts.payoneer.com/partners/or.aspx?pid=rq7Aw%2bDhQx7gTkBitRw5Qg%3d%3d&utm_source=affiliates&utm_medium=EducacionIT&utm_campaign=Tracking&transaction_id=102e6a55664d95275b59c318b528a8&offer_id=399&aff_id=42435&rcid=200495


https://register.payoneer.com/es/solution/educacionit/

































#########################################################################################################
*** NOTAS ***
#########################################################################################################
"Dejar de empezar y empeza a terminar"
shutdown -h 22:45 “A las 22:53 de la madrugada el sistema va a ser apagado”
sudo systemctl disable NetworkManager && sudo systemctl stop NetworkManager ; sudo systemctl restart network.service
Ser participativo, autónomo y proactivo, con ganas de opinar y contribuir en cómo trabajamos en el equipo.

#########################################################################################################
*** NOTAS ***
#########################################################################################################


###########################
*** ROADMAP  DEVOPS/SRE ***
###########################

1. Git 
2. Linux (basic administrar servidores)
3. Networking (REDES) (basico abrir puertos configurar firewal ) CCNA
4. Contenedores, Docker, POD,

*** continuos ingtegration, continuos delilvery *** 

5. Heramientas de contruccion , MAven, grada para JAVA, NPM para javascritp 
 - Repositorio de artefacto // Nexus, DOCKER HUB
 - Automatizar el build : Jenkins, gitlab, github action

6. AWS, aprende un solo proveedor, solo aprende los servicios que necesitas
7. Orquestacion de contenedores Kubernetes, Docker Compose
8. Monitoreo, prometheus, nagios, graphana, cloudwatch (envia mensajes al celular del admin)
9. Infraestructura como codigo (definir todo lo que la infraestructura necesita en archivos y luego desplegar esto de forma automatica)
-  Ambientes de produccion, pruebas, desarollo
-  Herramientas de aprovisionamiento, para crear infraestructura por ej:Terraform es agnostico, cludformation es para AWS y solo sirve para AWS
-  Gestion de configuracion: ANSIBLE, CHEF, PUPPET


10. Lenguajes de Scripting
   - BASH
   - python
   - go
   - Ruby






























































































