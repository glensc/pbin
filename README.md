# pbin

CLI tool for [Stikked](https://github.com/claudehohl/Stikked) based pastebin 
services, like [http://paste.mate-desktop.org/](http://paste.mate-desktop.org/).

Inspired by [mpaste](https://github.com/mate-desktop/mate-desktop/blob/1.8/tools/mpaste) 
from [mate-desktop](http://mate-desktop.org/), but without the Python dependency 
and with some added features (such as file type detection).

## Installing

Clone or download this repository.  Change into that directory. 
Copy `pbin.sh` from this repository to somewhere in your `$PATH`, 
such as `~/.local/bin/pbin`.  

You may alter the script to include your endpoint and API key, or you may put 
them in your `.profile` or `.bashrc` like so:

```
export PASTE_URL='https://URL OF YOUR INSTANCE/paste/api/create'
export PASTE_APIKEY='YOUR API KEY'
```

## Usage

```
Usage: pbin [options] < [input_file]

Options:
  -v, --verbose   Verbose mode; does not use xsel or xclip
  -a, --apikey    API key for the server
  -t, --title     title of this paste
  -n, --name      author of this paste
  -p, --private   should this paste be private
  -l, --language  language this paste is in
  -e, --expire    paste expiration in minutes
  -r, --reply     reply to existing paste
```

If [xclip](https://linux.die.net/man/1/xclip) or [xsel](https://linux.die.net/man/1/xsel) is in 
your $PATH, `pbin` will automatically use `xclip` to put the result on the 
primary clipboard and `xsel` to put the result on the "clipboard" clipboard if
it is not in "verbose" mode.  `pbin` will always output the URL to STDOUT.

## Copyright

License: GPL v2

(c) 2014-2018 Elan Ruusamäe <glen@pld-linux.org>
