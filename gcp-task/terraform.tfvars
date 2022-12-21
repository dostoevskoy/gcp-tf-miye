project_id = "gcp-tf-8934"

vpcs = {
  "vpc1" : {
    vpc_name        = "tf-vpc-int"
    vpc_description = "Tf managed internal faced vcp"
    "subnets" : {
      "pub" : {
        subnet_name      = "sub-pub-int"
        subnet_ip        = "10.101.0.0/24"
        subnet_flow_logs = "true"
      },
      "priv" : {
        subnet_name      = "sub-priv-int"
        subnet_ip        = "10.101.1.0/24"
        subnet_flow_logs = "true"
      },
      "db" : {
        subnet_name      = "sub-db-int"
        subnet_ip        = "10.101.2.0/24"
        subnet_flow_logs = "true"
      }
    }
    firewalls = {
      "ssh" : {
        name      = "tf-allow-ssh-ingress-int"
        direction = "INGRESS"
        ranges    = ["35.235.240.0/20"]
        allow = [{
          protocol = "tcp"
          ports    = ["22"]
        }]
        deny = []
      },
      "allow-internal" : {
        name      = "tf-allow-internal-communications-int"
        direction = "INGRESS"
        ranges    = ["10.101.0.0/16", "10.102.0.0/16"]
        allow = [{
          protocol = "tcp"
          ports    = ["0-65535"]
          },
          {
            protocol = "udp"
            ports    = ["0-65535"]
          }
        ]
        deny = []
      },
      "allow-icmp" : {
        name      = "tf-allow-icmp-int"
        direction = "INGRESS"
        ranges    = ["10.101.0.0/16", "10.102.0.0/16"]
        allow = [{
          protocol = "icmp"
          ports    = []
          }
        ]
        deny = []
      }
    }
  }
  "vpc2" : {
    vpc_name        = "tf-vpc-live"
    vpc_description = "Tf managed external faced vcp"
    "subnets" : {
      "pub" : {
        subnet_name      = "sub-pub-live"
        subnet_ip        = "10.102.0.0/24"
        subnet_flow_logs = "true"
      },
      "priv" : {
        subnet_name      = "sub-priv-live"
        subnet_ip        = "10.102.1.0/24"
        subnet_flow_logs = "true"
      },
      "db" : {
        subnet_name      = "sub-db-live"
        subnet_ip        = "10.102.2.0/24"
        subnet_flow_logs = "true"
      }
    }
    firewalls = {
      "ssh" : {
        name      = "tf-allow-ssh-ingress-live"
        direction = "INGRESS"
        ranges    = ["0.0.0.0/0"]
        allow = [{
          protocol = "tcp"
          ports    = ["22"]
        }]
        deny = []
      },
      "allow-internal" : {
        name      = "tf-allow-internal-communications-live"
        direction = "INGRESS"
        ranges    = ["10.101.0.0/16", "10.102.0.0/16"]
        allow = [{
          protocol = "tcp"
          ports    = ["0-65535"]
          },
          {
            protocol = "udp"
            ports    = ["0-65535"]
          }
        ]
        deny = []
      },
      "allow-icmp" : {
        name      = "tf-allow-icmp-live"
        direction = "INGRESS"
        ranges    = ["10.101.0.0/16", "10.102.0.0/16"]
        allow = [{
          protocol = "icmp"
          ports    = []
          }
        ]
        deny = []
      }
    }
  }
}

vpc-peerings = [
  {
    peering_name = "int-live",
    network      = "tf-vpc-int"
    peer_network = "tf-vpc-live"
  },
  {
    peering_name = "live-int",
    network      = "tf-vpc-live"
    peer_network = "tf-vpc-int"
  },
]


vm_nets = [
  {
    env = "int",
    subnetwork = "sub-pub-int"
  },
  {
    env = "live",
    subnetwork = "sub-pub-live"
  },

]