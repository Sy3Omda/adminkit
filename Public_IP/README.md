### Use a bash script to receive notifications on your home modem's public IP address even if it changes.

The main goal of this script is to run continuously in the background and notify you whenever the public IP changes.

Installation of `golang` and `notify` were required.

```
go install -v github.com/projectdiscovery/notify/cmd/notify@latest
```