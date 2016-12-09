# Environment Variables for Cloud v5 #

This cookbook allows you to set environment variables for any application server that sources `/data/INSERT_APP_NAME/shared/env.custom`.

As this is a system-level configuration, the environment variables configured by this cookbook are available to all applications in the affected environment. That being the case, you'll want to ensure that applications in multi-application environments are configured to use the correct environment variables and that those environment variable names don't conflict.

## Usage ##

To enable this cookbook, you need to do the following:

* Add the cookbook to your custom cookbooks collection
* Enable the cookbook in `ey-custom`
* Upload your custom cookbooks to your environment
* Apply changes to your environment

### Enabling the Cookbook ###

The first thing to do to enable this cookbook is to let the `ey-custom` cookbook know about it. You do this by adding it as a dependency in `ey-custom/metadata.rb`:

```
depends "env_vars"
```

Now that `ey-custom` knows about `env_vars`, you should instruct `ey-custom` to run it befor the main cookbooks via `ey-custom/recipes/before_main.rb`:

```
include_recipe "env_vars"
```

## Supported Processes ##

The following application servers and utilities honor the environment variables configured by this cookbook:

* Passenger (see below)
* PHP-FPM
* Sidekiq
* Unicorn

If Passenger is used, a Ruby wrapper script is created and the passenger_ruby directive is added in the Nginx configuration.  This script just sources the env.custom file and calls Ruby.

## Setting Environment Variables ##

Set environment variables in `env_vars/attributes/default.rb`. This is what the file contains by default, and you can remove or modify any of this content:

```
default[:env_vars] = {
  :RUBY_HEAP_MIN_SLOT => "10000",
  :RUBY_HEAP_SLOTS_INCREMENT => "10000",
  :RUBY_HEAP_SLOTS_GROWTH_FACTOR => "1.8",
  :RUBY_GC_MALLOC_LIMIT => "8000000",
  :RUBY_HEAP_FREE_MIN => "4096",
}
```

## Bonus: Make Environment Variables Available in the Shell ##

Let's say that your app is named Frank. To make the environment variables that you've configured available in your shell (and therefore the Rails console, etc), you'll need to update your user's Bash profile. To do this, add the following to `~/.bash_profile`:

```
[[ -f /data/Frank/shared/config/env.custom ]] && . /data/Frank/shared/config/env.custom
```

After closing your connection and logging back in, you should be able to see your custom environment variables in the output of `env`.
