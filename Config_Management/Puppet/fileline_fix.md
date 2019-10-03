`file_line` appends to the last line of text (instead of a new line) if there's no blank line at the end of a file (bug?); this is a workaround (should be idempotent).

```
exec { "ensure_newline_${name}":
    command  => "echo \"\" >> ${user_shell_file}",
    unless   => "[ -z \"$(tail -1 ${user_shell_file})\" ]",
    provider => shell,
    path     => '/usr/bin',
}

file_line { "source_shell_${name}":
    ensure  => 'present',
    path    => $user_shell_file,
    line    => "source ${hb_shell_file}",
    require => Exec["ensure_newline_${name}"],
}
```

