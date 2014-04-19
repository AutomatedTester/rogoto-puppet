exec { "sudo apt-get update":
  path => "/usr/bin",
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

class { 'apache': }

apache::vhost { 'rogoto.com':
  port                    => '3000',
  docroot                 => '/tmp/rogoto-http/',
  wsgi_application_group  => '%{GLOBAL}',
  wsgi_daemon_process     => 'rogoto',
  wsgi_script_aliases     => { '/' => ' /tmp/rogoto-http' }
}

class { 'apache::mod::wsgi':
  wsgi_socket_prefix => "\${APACHE_RUN_DIR}WSGI",
  wsgi_python_home   => '/tmp/http_venv',
  wsgi_python_path   => '/tmp/http_venv/site-packages',
}
package { "libapache2-mod-wsgi":
  ensure  => present,
  require => Exec["sudo apt-get update"]
}
