# Using create_resources

## Manually

	user { 'brad':
	  home  => '/home/bfrank',
	  shell => '/bin/fish',
	}
	
	user { 'sarah':
	  home => '/home/slduncan',
	  shell => '/bin/crab',
	}
	
	user { 'emily':
	  home => '/opt/elawrence',
	  shell => '/bin/fish',
	}


## With create_resources

	$users = {
	  'brad'  => { 'home' => '/home/bfrank', shell => '/bin/fish' },
	  'sarah' => { 'home' => '/home/sarah', shell => '/bin/tsch' },
	  'emily' => { 'home' => '/opt/elawrence', shell => '/bin/tsch' },
	}
	
	create_resources(user, $users)


### Adding Default Settings

	$default_user_settings = {
	  'shell' => '/bin/tsch'
	}
	
	$users = {
	  'brad'  => { 'home' => '/home/bfrank', shell => '/bin/fish' },
	  'sarah' => { 'home' => '/home/sarah', },
	  'emily' => { 'home' => '/opt/elawrence', },
	}
	
	create_resources(user, $users, $default_user_settings)


## With A Custom Function

	$default_user_settings = {
	  'shell' => '/bin/tsch'
	  'home'  => '/home/',
	}
	
	$users = {
	  'bfrank'    => { shell => '/bin/fish' },
	  'slduncan'  => { },
	  'elawrence' => { home => '/opt/' },
	}
	
	create_resources('create_user', $users, $default_user_settings)
	
	define create_user {
	  $home_dir = "${home}/${title}"
	  user { $title:
	    home => $home_dir,
	    shell => $shell,
	  } ->
	  file { $home_dir:
	    ensure => 'directory',
	  }
	}
