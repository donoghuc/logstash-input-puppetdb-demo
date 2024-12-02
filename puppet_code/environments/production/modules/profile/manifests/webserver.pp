class profile::webserver {
  package { ['nginx', 'apache2']:
    ensure => present,
  }

  file { '/var/www/html':
    ensure => directory,
    mode   => '0755',
  }

  # Simulate config changes
  file { '/etc/nginx/conf.d/status.conf':
    ensure  => file,
    content => "# Generated at ${strftime('%Y-%m-%d %H:%M:%S')}\nserver {\n  listen 80;\n  location /status {\n    stub_status on;\n  }\n}\n",
  }
}