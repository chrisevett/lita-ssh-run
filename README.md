# lita-ssh-run

This will allow you to run commands via ssh and powershell via winrm
Example:
`Lita, run uptime on 192.168.1.10`
`Lita, run Get-Service on 192.168.1.20`

Usernames, passwords, and OS type are stored in redis memory by chat userid and host passed. **Tested on slack and hipchat**
If not found, it will prompt via private message on how to enter user, password, and OS:
Currently passwords are passed via plaintext in private message. I have requested to Slack to add an obfuscation format block for things like this.


## Installation

Add lita-ssh-run to your Lita instance's Gemfile:

``` ruby
gem "lita-ssh-run"
```

## Configuration

None

## Usage

`Lita, run uptime on 192.168.1.10`

`Lita, set username for 192.168.1.0 to USERNAME`

`Lita, set password for 192.168.1.0 to PASSWORD`

`Lita, set OS for 192.168.1.0 to linux`

`Lita, set OS for 192.168.1.0 to windows`

`List, set port for 192.168.1.0 to 2222`


## License

[MIT](http://opensource.org/licenses/MIT)
