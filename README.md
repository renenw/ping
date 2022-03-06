This (tiny!) script monitors the state of my network. It calls the operating system's `ping` command to compute the `packet_loss_percentage` and `rtt` (how long it takes to get a reply - _the "ping" time_).

The script returns a JSON object which I push to a [Home Assistant](https://www.home-assistant.io/)  instance running on another Pi.
# Examples
## Basics
Ping the AWS US East data centre:
`ruby ping.rb 3.80.0.0`
Returns:
```
{
  "target": "3.80.0.0",
  "pings": 10,
  "packet_loss_percentage": "0",
  "rtt": {
    "min": "239.979",
    "avg": "241.792",
    "max": "243.560",
    "stddev": "0.995"
  }
}
```
## More Interesting
This pings a AWS's US East gateway (us-east-1; `3.80.0.0`) and then `POST`s the result to web server running on the local network:

`bash -c 'ruby ping.rb     3.80.0.0 | curl -H "Content-Type: application/json" -X POST -d "$(</dev/stdin)" http://192.168.0.252:3553/?source=ping_us_east_1' `
## Cron
I test the network speeds to key Amazon [data centres](http://ec2-reachability.amazonaws.com/) and push the result to [Home Assistant](https://www.home-assistant.io/) via a simple [relay](https://github.com/renenw/relay), using the following cron:
```
   *  *    *   *   *   bash -c 'ruby ping/ping.rb     3.80.0.0 | curl -H "Content-Type: application/json" -X POST -d "$(</dev/stdin)" http://192.168.0.252:3553/?source=ping_us_east_1'                                      > /dev/null 2>&1
   *  *    *   *   *   bash -c 'ruby ping/ping.rb    3.248.0.0 | curl -H "Content-Type: application/json" -X POST -d "$(</dev/stdin)" http://192.168.0.252:3553/?source=ping_eu_west_1'                                      > /dev/null 2>&1
   *  *    *   *   *   bash -c 'ruby ping/ping.rb 13.245.0.253 | curl -H "Content-Type: application/json" -X POST -d "$(</dev/stdin)" http://192.168.0.252:3553/?source=ping_af_south_1'                                     > /dev/null 2>&1
```
# Setup
## Dependencies
### Ruby
Only real dependency is Ruby. To install Ruby on Raspbian I followed [these](https://www.anegron.site/2020/01/30/installing-rbenv-and-ruby-on-raspberry-pi/) instructions (I appended the detail in step 4 to the end of my `.bashrc` file and then rebooted before proceeding to install. 

I concluded the process by installing Ruby 3.1.1:
```
rbenv install 3.1.1
rbenv global 3.1.1
```
*NB* This installation process takes a long while.
### Ping
It also requires `ping`. But, if you don't have access to ping, you are on your own!
