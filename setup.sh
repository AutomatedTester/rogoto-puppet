apt-get update && sudo apt-get install puppet -y
puppet module install puppetlabs-vcsrepo;
puppet module install puppetlabs/nodejs;
puppet module install puppetlabs/apache;
puppet module install stankevich-python;
puppet module install camptocamp-augeas;
