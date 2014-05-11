include augeas

exec { "sudo apt-get update":
  path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
}

package { 'git':
  ensure  => installed,
  require => Exec["sudo apt-get update"]
}

vcsrepo { "/var/www/rogoto-http/":
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

python::virtualenv { '/var/www/http_venv':
  ensure       => present,
  version      => 'system',
  requirements => '/var/www/rogoto-http/requirements.txt',
  systempkgs   => true,
  distribute   => false,
  cwd          => '/var/www/rogoto-http/',
  timeout      => 0,
  require      => Vcsrepo["/var/www/rogoto-http/"]
}

class { 'apache': }

apache::vhost { 'rogoto.com':
  port                    => '80',
  docroot                 => '/var/www/rogoto-http/',
  wsgi_daemon_process     => 'rogoto python-path=/var/www/rogoto-http:/var/www/http_venv/lib/python2.7/site-packages processes=1 threads=1 maximum-requests=1',
  wsgi_script_aliases     => { '/' => '/var/www/rogoto-http/rogoto.wsgi' }
}

class { 'apache::mod::wsgi':
  wsgi_socket_prefix => "\${APACHE_RUN_DIR}WSGI",
  wsgi_python_home   => '/var/www/http_venv',
  wsgi_python_path   => '/var/www/http_venv/site-packages',
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
  require => Augeas["/etc/modules"]
}

package { "libi2c-dev":
  ensure => installed,
  require => Exec["sudo apt-get update"]
}

package { "i2c-tools":
  ensure => installed,
  require => Augeas["/etc/modules"]
}

exec { "gpio":
  command => "gpio load i2c 10",
  path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
  require => Package["libi2c-dev"]
}

augeas { "/etc/inittab#respawn":
  changes => [ "rm T0:23:respawn:/sbin/getty -L ttyAMA0 115200 vt100"],
  context => "/files/etc/inittab"
}

augeas { "init_uart_clock":
  changes => ["set init_uart_clock '32000000'"],
  context => "/files/boot/config.txt"
}

augeas { "/boot/cmdline.txt":
  changes => ["rm console=ttyAMA0,115200 kgdboc=ttyAMA0,115200"],
  context => "/files/boot/cmdline.txt"
}

augeas { "/etc/modprobe.d/raspi-blacklist.conf":
  changes => ["rm blacklist i2c-bcm2708"],
  context => "/files/etc/modprobe.d/raspi-blacklist.conf"
}

augeas { "/etc/modules":
  changes => ["set i2c-dev ''"],
  context => "/etc/modules"

}