# potatodebian
utilities and stuff for me when reinstalling 

add yourself to sudoers

`su root `
`nano /etc/sudoers `

add at the bottom
`user_name ALL=(ALL:ALL)  ALL`

 next: setup a package mirror so you can install stuff
`sudo nano /etc/apt/sources.list`

replace the whole file with sources.list

sync your time if needed so apt can shut up

`sudo timedatectl set-ntp-true`

if that fails install a timedate service 
`sudo apt install systemd-timesyncd`
