# Class: nodesjs
#
# Description:
#  Ensure all needed install tools are availeable and install nodejs from source
#
# Usage:
# `include nodejs`
class nodejs {
  $package_name = 'node-v0.6.12'
  $package_tar = '$package_name.tar.gz'
  $package_path = 'puppet:///modules/nodejs/$package_tar'
  $home_path = '/home/node/opt'

  user { "node":
    ensure => "present",
    home => "/home/node"
  }

  package { "openssl":
    ensure => "installed"
  }

  package { "openssl-devel":
    ensure => "installed"
  }

  package { "gcc-c++":
    ensure => "installed"
  }

  file { "/home/node":
    ensure => "directory",
    owner => "node"
  }

  file { "${home_path}":
    ensure => "directory",
    require => File["/home/node"],
    owner => "node"
  }

  file { "/home/node/.bashrc":
    ensure => "present",
    owner => "node",
    content => template('nodejs/node_bashrc.erb')
  }

  file { "/tmp/${package_tar}":
    source => "${package_path}",
    ensure => "present",
    owner => "node",
    group => "node"
  }

  exec { "extract_node":
    command => "tar -xzf ${package_tar}",
    cwd => "/tmp",
    path => ["/usr/bin", "/usr/sbin", "/bin"],
    creates => "/tmp/${package_name}",
    require => [File["/tmp/${package_tar}"], User["node"]],
    user => "node"
  }

  exec { "bash ./configure --prefix=${home_path}":
    alias => "configure_node",
    cwd => "/tmp/${package_name}",
    path => ["/usr/bin", "/usr/sbin", "/bin"],
    require => [Exec["extract_node"], Package["openssl"], Package["openssl-devel"], Package["gcc-c++"]],
    timeout => 0,
    creates => "/tmp/${package_name}/.lock-wscript",
    user => "node"
  }

  file { "/tmp/${package_name}":
    ensure => "directory",
    owner => "node",
    group => "node",
    require => Exec["configure_node"]
  }

  exec { "make_node":
    command => "make",
    cwd => "/tmp/${package_name}",
      path => ["/usr/bin", "/usr/sbin", "/bin"],
    require => Exec["configure_node"],
    timeout => 0,
    user => "node"
  }

  exec { "install_node":
    command => "make install",
    cwd => "/tmp/${package_name}",
    require => Exec["make_node"],
    path => ["/usr/bin", "/usr/sbin", "/bin"],
    timeout => 0,
    creates => "${home_path}/bin/node",
    user => "node"
  }

  file { "${home_path}/bin/node":
    owner => "node",
    group => "node",
    require => Exec["install_node"],
    recurse => true
  }

  file { "${home_path}/bin/node-waf":
    owner => "node",
    group => "node",
    recurse => true,
    require => Exec["install_node"]
  }

}

