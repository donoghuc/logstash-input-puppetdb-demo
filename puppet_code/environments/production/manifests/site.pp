node default {
  include profile::base
}

node /^agent[1-2]/ {
  include profile::base
  include profile::webserver
}

node /^agent[3-4]/ {
  include profile::base
  include profile::database
}