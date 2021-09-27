output "terrform-output" {
  value = <<EOF

    +:.                                        
    ssso/-`                                    
    sssssss+:.                                 
    sssssssssso/-                              
    sssssssssssss`-:.                       -/`
    sssssssssssss`:sso/-`               .:oyhy`
    sssssssssssss`:ssssss+:.        `-+syyyyyy`
    +ssssssssssss`:ssssssssso/-` .:oyhyyyyyyyy`
      .:ossssssss`:ssssssssssss/ hyyyyyyyyyyyy`
         `-/ossss`:ssssssssssss/ hyyyyyyyyyyyy`
             .:+o`:ssssssssssss/ hyyyyyyyyyyyy`
                ` -osssssssssss/ hyyyyyyyyyyyo`
                  ...:ossssssss: hyyyyyyyy+:`  
                  :so/-.-/ossss: hyyyys/.      
                  :ssssso:..:os: hy+:`         
                  :sssssssso/-.` .             
                  :ssssssssssss:               
                  :ssssssssssss/               
                  :ssssssssssss/               
                  :ssssssssssss/               
                   .:+sssssssss/               
                      `-/osssss/               
                          .:+ss/               
                             `-.                              
    
    
    Your IP Address is: ${local.myip}
    
    You can access the bastion server with:
    
      ssh -l ${var.ssh_user} ${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip}

    Bastion Server:
      External IP:   ${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip}
      Internal IP:   ${google_compute_instance.bastion.network_interface[0].network_ip}

    Consul Server:
      External VIP:  ${google_compute_global_address.consul-external.address}
      Internal VIP:  ${google_compute_address.consul-internal.address}
EOF
}
