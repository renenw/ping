require 'json'

target  = ARGV[0]
COUNT   = 10

if target.nil? || target==''
  p 'A target server is required' 
else
  results = `ping -c#{COUNT} -q #{target}`
  details = results.split(/\n/)

  packet_loss_percentage = details.last(2)[0][/(\d{1,3})\%\spacket/,1]
  rtt = details.last.split(' ')
  h = {
    target:                 target,
    pings:                  COUNT,
    packet_loss_percentage: details.last(2)[0][/(\d{1,3})\%\spacket/,1],
    rtt:                    rtt[1].split('/').zip(rtt[3].split('/')).to_h,
  }
  
  STDOUT.puts h.to_json
end
