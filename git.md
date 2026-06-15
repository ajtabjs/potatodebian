install git credential manager
`sudo apt install -y git-credential-oauth`
setup with 
```
git config --global --unset-all credential.helper
git config --global --add credential.helper "cache --timeout 21600" # six hours
git config --global --add credential.helper oauth```
