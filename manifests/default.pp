exec { "sudo apt-get update":
  path => "/usr/bin",
}
package { "apache2":
  ensure  => present,
  require => Exec["sudo apt-get update"],
}

service { "apache2":
  ensure  => "running",
  require => Package["apache2"],
}

package { "python-dev":
  ensure => installed,
  require => Exec["sudo apt-get update"]
}

package { "python-pip":
  ensure => installed,
  require => Exec["sudo apt-get update"]
}

package { 'git':
  ensure => installed,
  require => Exec["sudo apt-get update"]
}

vcsrepo { "/tmp/rogoto-http/":
    require => Package['git'],
    ensure => present,
    provider => git,
    source => "https://github.com/AutomatedTester/rogoto-http.git"
}