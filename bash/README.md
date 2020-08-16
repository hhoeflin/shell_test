# Execution of configuration files in bash

The rules for when which configuration files are executed on linux for which shell can 
be quite challenging to remember (at least for users that don't use this functionality every day). 
The setup becomes even more challenging when used together with Docker, where it is a priori
less clear which type of shell is in use when. In this writeup, I will only use *bash*.

In order to make this easier for me to remember I decided to create a small docker container 
that shows which configuration files are run in which order under different conditions. 

In order to compile this Dockerfile and writeup I used various sources on the internet. A good 
introduction to the subject is [GNU - Bash Startup Files](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html). 
Another very nice post is [Bash interactive, login shell types](https://transang.me/bash-interactive-login-shells/).

## Type of shells

For shells, there are two properties that each shell has. It is either a _login_ or a _non-login_ shell. And it
is either an _interactive_ or _non-interactive_ shell.

### Login shells

A login shell is typically started when e.g. ssh-ing or logging into a computer. In it, certain startup scripts are
sourced that can be used to set the initial values for environment varialbles, e.g. PATH. A new bash shell can be
explicitly turned into a login shell by using the _-l_ or _--login_ options. 


### Interactive shells

An interactive shell is a shell that has its input, output and error streams connected to a terminal. This is typically
the case when you start a shell inside another shell (e.g. inside tmux). The typical case of a non-interactive
shell is a shell that is started in order to run a script (e.g. with a shebang in the first line). The option _-i_
can be used to explicitly turn a shell into an interactive shell.

In addition to these option there are other switches that can be used to customize the behaviour which startup 
scripts get run and we will go over them and their effects later. .

## Configuration files

There are a number of different configuration files that are sourced in different situations. Here an overview
of the ones relevant for bash:

- */etc/profile:* This system-wide script is sourced by *login*-shells at startup before any other files are sourced 
- */etc/profile.d:* A system-wide directory from which additional scripts are sourced by *login* shells. While not formally listed in the 
  GNU manual linked above, most distributions also read all scripts in this directory.
- *~/.bash_profile, ~/.bash_login, ~/.profile:* These are scripts for individual users that are read by *login* shells. Only 
  the first of these scripts that exists and is readable is used. If the option _--noprofile_ is used, none of these scripts
  is sourced.
- */etc/bashrc or /etc/bash.bashrc:* A system-wide script that is sourced by *interactive* shells. 
  CentOS uses _/etc/bashrc_ whereas Debian-based systems use _/etc/bash.bashrc_. 
- *~/.bashrc:* This user-specific script is sourced for all *interactive* shells. If the option _--norc_ is used, this 
  file is not being sourced. If the option _--rcfile file_ is being used, _file_ is sourced instead of _~/.bashrc_. 
- *$BASH\_ENV:* If a non-interactive shell is started and the environment variable _BASH\_ENV_ exists, then 
  the script file referenced in _BASH\_ENV_ will be sourced.


### Behaviour for sh

When bash is invoked with the name _sh_, then its behviour changes. 

- *login:* This behviour occurs when _sh_ is started with the _--login_ option. It sources _/etc/profile_ and _~/.profile_ 
  in this order. The _--noprofile_ prevents this (clarify if it prevents
  reading of both files or only one of them).
- *interactive:* It looks for the environment variable _ENV_ and sources the file referenced here. The option _--rcfile_ has
  no effect.
- *non-interactive:*: No startup files are being sourced.


### POSIX mode:

When started in POSIX mode, only the file referenced in the variable _ENV_ is sourced. No other files are sourced.


## Docker containers

Now that we have reviewed all those different configuration files and options, let's create a Docker container where
we can see all of these in action.

We demonstrate in which order which file gets loaded by appending an echo command with the file name to each 
script file if it exists - and create it with just the echo command otherwise. In additon to this we also
create a second version in which each script file is replaced by a version that replaces it with just the echo command.
We do this to highlight certain behaviors that are often stated in some articles to be part of the shell, but are 
really just behaviors of typical default configuration scripts. 

### A standard bash shell

So first we try out what happens if we are just asking for a standard shell in a docker run command (where 
we also have no _CMD_ and no _ENTRYPOINT_ in the container.

```bash
docker run hhoeflin/shell_test:bash-append /bin/bash
```

As we can see, this sources no files at all. But when we now set the _BASH\_ENV_ variable to _/etc/profile, we see
that the script gets loaded - together with the script file in _/etc/profile.d_.

```bash
docker run -e BASH_ENV=/etc/profile hhoeflin/shell_test:bash-append /bin/bash
```

Strictly speaking the script in _/etc/profile.d_ should not have been loaded - at least we did not explicitly ask
for it. The reason is that all script in _/etc/profile.d_ get sourced by the default _/etc/profile_. We confirm 
this by running the same command, but this time using the version of the configuration scripts that got replaced with
the echo commands - not appended to.

```bash
docker run -e BASH_ENV=/etc/profile hhoeflin/shell_test:bash-replace /bin/bash
```





