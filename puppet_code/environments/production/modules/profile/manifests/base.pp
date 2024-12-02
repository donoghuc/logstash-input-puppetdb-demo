class profile::base {
  # Ensure apt-get update runs first
  exec { 'apt-update':
    command     => '/usr/bin/apt-get update',
    logoutput   => true,
    returns     => [0, 100],
  }

  file { '/etc/motd':
    ensure  => file,
    content => "Welcome to ${facts['hostname']}\nNode Group: ${facts['node_group']}\n",
  }

  # Make sure apt-update runs before any package installation
  Package {
    require => Exec['apt-update'],
  }

  # Simulate some packages
  package { ['vim', 'curl', 'wget']:
    ensure => present,
  }

  # Create a status file that changes regularly
  file { '/var/lib/node_status':
    ensure  => file,
    content => "Last update: ${strftime('%Y-%m-%d %H:%M:%S')}\nUptime: ${facts['system_uptime']['uptime']}\n",
  }
}