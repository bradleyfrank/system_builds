# Puppet Notes

## Command Line

Generate a new Puppet module:

`puppet module generate bfrank-bootstrap`

A local Puppet apply:

`puppet apply /path/to/site.pp --hiera_config /path/to/hiera.yaml --modulepath=/path/to/modules/`

## Modules

Debug with notify:

`notify { "The value is: ${variable_name}": }`

## Snippets

* [Using `create_resources`](create_resources.md): An example of creating users manually and with `create_resources`, also with a custom function.
* [`file_line` fix](fileline_fix.md): A fix for `file_line` not appending a newline to a file.
