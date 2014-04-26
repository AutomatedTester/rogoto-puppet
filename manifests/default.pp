user { "rogoto":
  comment => "rogoto",
  home => "/home/rogoto",
  ensure => present,
  #shell => "/bin/bash",
  #uid => '501',
  #gid => '20'
}

exec { "sudo apt-get update":
  path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
  require => User["rogoto"]
}

package { 'git':
  ensure  => installed,
  require => Exec["sudo apt-get update"]
}

vcsrepo { "/home/rogoto/rogoto-http/":
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

python::virtualenv { '/home/rogoto/http_venv':
  ensure       => present,
  version      => 'system',
  requirements => '/home/rogoto/rogoto-http/requirements.txt',
  systempkgs   => true,
  distribute   => false,
  cwd          => '/home/rogoto/rogoto-http',
  timeout      => 0,
  require      => Vcsrepo["/home/rogoto/rogoto-http/"]
}

class { 'apache': }

apache::vhost { 'rogoto.com':
  port                    => '80',
  docroot                 => '/home/rogoto/rogoto-http/',
  wsgi_daemon_process     => 'rogoto python-path=/home/rogoto/rogoto-http:/home/rogoto/http_venv/lib/python2.7/site-packages processes=1 threads=1 maximum-requests=1',
  wsgi_script_aliases     => { '/' => '/home/rogoto/rogoto-http/rogoto.wsgi' }
}

class { 'apache::mod::wsgi':
  wsgi_socket_prefix => "\${APACHE_RUN_DIR}WSGI",
  wsgi_python_home   => '/home/rogoto/http_venv',
  wsgi_python_path   => '/home/rogoto/http_venv/site-packages',
}

package { "libapache2-mod-wsgi":
  ensure  => present,
  require => Exec["sudo apt-get update"]
}

package { "python-serial":
  ensure => installed,
  require => Exec["sudo apt-get update"]
}

package { "python-rpi.gpio":
  ensure => installed,
  require => Exec["sudo apt-get update"]
}

package { "python-smbus":
  ensure => installed,
  require => Exec["sudo apt-get update"]
}

package { "libi2c-dev":
  ensure => installed,
  require => Exec["sudo apt-get update"]
}