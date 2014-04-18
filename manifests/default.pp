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

package { "libapache2-mod-wsgi":
  ensure  => present,
  require => Exec["sudo apt-get update"]
}

package { 'git':
  ensure  => installed,
  require => Exec["sudo apt-get update"]
}

vcsrepo { "/tmp/rogoto-http/":
    require  => Package['git'],
    ensure   => present,
    provider => git,
    source   => "https://github.com/AutomatedTester/rogoto-http.git"
}

class { 'python':
  version    => 'system',
  dev        => true,
  virtualenv => true,
  pip        => true,
}

python::virtualenv { '/tmp/http_venv':
  ensure       => present,
  version      => 'system',
  requirements => '/tmp/rogoto-http/requirements.txt',
  systempkgs   => true,
  distribute   => false,
  cwd          => '/tmp/rogoto-http',
  timeout      => 0,
  require      => Vcsrepo["/tmp/rogoto-http/"]
}
