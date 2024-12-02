class profile::database {
  package { ['mysql-client', 'postgresql-client']:
    ensure => present,
  }

  # Simulate database config
  file { '/etc/db_config':
    ensure  => file,
    content => "# DB Config generated at ${strftime('%Y-%m-%d %H:%M:%S')}\nmax_connections=100\nwork_mem=4MB\n",
  }
}