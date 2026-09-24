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

