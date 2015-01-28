# lita-ssh-run

This will allow you to run commands via ssh
Example:
`Lita, run uptime on 192.168.1.10`

Usernames and passwords are stored in redis memory by chat userid and host passed. **Only tested on slack**
If not found, it will prompt via private message on how to enter user and password:
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


## License

[MIT](http://opensource.org/licenses/MIT)
