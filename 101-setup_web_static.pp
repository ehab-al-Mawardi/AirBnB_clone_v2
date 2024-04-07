# Configures a web server for deployment of web_static.

# Nginx configuration
$nginx_conf = "
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    add_header X-Served-By ${hostname};
    root   /var/www/html;
    index  index.html index.htm;
    location /hbnb_static {
        alias /data/web_static/current;
        index index.html index.htm;
    }
    location /redirect_me {
        return 301 https://th3-gr00t.tk;
    }
    error_page 404 /404.html;
    location /404 {
      root /var/www/html;
      internal;
    }
}"

# Install Nginx package
package { 'nginx':
  ensure   => 'present',
  provider => 'apt',
}

# Create directory structure
file { ['/data', '/data/web_static', '/data/web_static/releases', '/data/web_static/releases/test', '/data/web_static/shared']:
  ensure => 'directory',
}

# Create test index.html
file { '/data/web_static/releases/test/index.html':
  ensure  => 'present',
  content => "Holberton School Puppet\n",
}

# Create symbolic link
file { '/data/web_static/current':
  ensure => 'link',
  target => '/data/web_static/releases/test',
  require => File['/data/web_static/releases/test/index.html'],
}

# Set ownership
exec { 'chown -R ubuntu:ubuntu /data/':
  path => ['/usr/bin/', '/usr/local/bin/', '/bin/'],
}

# Ensure /var/www/html exists
file { '/var/www/html':
  ensure => 'directory',
}

# Create index.html and 404.html
file { ['/var/www/html/index.html', '/var/www/html/404.html']:
  ensure  => 'present',
  content => ["Holberton School Nginx\n", "Ceci n'est pas une page\n"],
}

# Nginx configuration file
file { '/etc/nginx/sites-available/default':
  ensure  => 'present',
  content => $nginx_conf,
  require => Package['nginx'],
  notify  => Exec['nginx_restart'],
}

# Restart Nginx service
exec { 'nginx_restart':
  command => '/etc/init.d/nginx restart',
  refreshonly => true,
}
