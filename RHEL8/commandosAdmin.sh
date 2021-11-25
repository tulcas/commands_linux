


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
**** Gestion de Permisos Sobre Archivos*****
#########################################################################################################

ls -ld #muestra pemisos de carpeta
chmod u-w C3/ #quita permisos de escritura
chmod u+w C3/ #suma permisos de escritura

chmod u=rwx,g=rwx,o=rwx C3/ #cambio de permisos a usuarios grupos y others #suma de permisos
chmod u-w,g-x,o-rwx C3/ #cambio de permisos a usuarios grupos y others #resta de permisos
chmod a-x C3/ #cambio de permisos a todos ALL #se quita ejecucion a todos
chmod a-w C3/  #cambio de permisos a todos ALL #se quita escritura a todos






Tecnologías



AWS certified cloud practitioner training



AWS Certified Cloud Practitioner



Nombre: Ricardo Andres Figuera
DNI: 30098572
Linea: 011-4304-0024








































Grupo 47 
rominalpantano@live.com Pantano Romina Laura 
lucianaporcel@gmail.com Porcel Luciana 
barbadoandres@gmail.com Figuera Ricardo 
davidm231@hotmail.com Martinez David



https://discord.gg/7p5yG2Kk











































echo "UUID=07d0c6cd-f65b-4449-a42f-7f25ad45818e  swap swap defaults 0 0" >> /etc/fstab (montar particion swap en fstab)

14 15  de SEPTIEMBRE
DIA1
https://teams.microsoft.com/dl/launcher/launcher.html?url=%2F_%23%2Fl%2Fmeetup-join%2F19%3Ameeting_ZWQzYmUyODItNDcwYS00OTdmLWI2YjAtNDA1ZDdjNDBmNDU3%40thread.v2%2F0%3Fcontext%3D%257B&type=meetup-join&deeplinkId=4716518e-d737-469c-9f75-a7cff0ce0646&directDl=true&msLaunch=true&enableMobilePage=true&suppressPrompt=true
DIA 2
https://teams.microsoft.com/dl/launcher/launcher.html?url=%2F_%23%2Fl%2Fmeetup-join%2F19%3Ameeting_YTNjNzY4ODMtZjBkNS00MGY5LTllNjEtMzQ5YmVkYzk5YmVh%40thread.v2%2F0%3Fcontext%3D%257b%2522Tid%2522%253a%2522e9c3f614-c8d9-4095-9ad4-87d2c9a7d8c4%2522%252c%2522Oid%2522%253a%252211a54601-a373-4388-a82e-7a7ed7101acb%2522%252c%2522IsBroadcastMeeting%2522%253atrue%257d%26btype%3Da%26role%3Da%26anon%3Dtrue&type=meetup-join&deeplinkId=9c4f150d-b7a4-4c2f-9a97-489b5ed71794&directDl=true&msLaunch=true&enableMobilePage=true&suppressPrompt=true









systemctl start vdo
systemctl enable vdo
systemctl status vdo









shutdown -h 22:45 “A las 22:53 de la madrugada el sistema va a ser apagado”



Ser participativo, autónomo y proactivo, con ganas de opinar y contribuir en cómo trabajamos en el equipo.







192.168.1.38
192.168.1.39


$ sudo vim /etc/sysconfig/network-scripts/ifcfg-fortibr10


DEVICE=fortibr10
STP=no
TYPE=Bridge
BOOTPROTO=none
DEFROUTE=yes
NAME=br10
ONBOOT=yes
DNS1=8.8.8.8
DNS2=192.168.1.1
IPADDR=192.168.1.39
PREFIX=24
GATEWAY=192.168.1.1



DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BRIDGE=fortibr10


sudo systemctl disable NetworkManager && sudo systemctl stop NetworkManager ; sudo systemctl restart network.service

nmcli connection down eno1 ; nmcli connection up eno1 



"Dejar de empezar y empeza a terminar"

OTERO JOSE LUIS Ver Informe Completo. Posible DNI, 16.224.872. CUIT/CUIL, 20-16224872-4. Edad Estimada, 58 años















