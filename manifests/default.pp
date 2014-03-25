include vcsrepo
exec { "apt-get update":
  path => "/usr/bin",
}
package { "apache2":
  ensure  => present,
  require => Exec["apt-get update"],
}
service { "apache2":
  ensure  => "running",
  require => Package["apache2"],
}
package { 'git':
        ensure => installed,
}

vcsrepo { "~/rogoto-http/":
    require => Package['git'],
    ensure => present,
    provider => git,
    source => "https://github.com/AutomatedTester/rogoto-http.git"
}