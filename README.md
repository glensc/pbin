pbin
====

CLI tool for [Stikked][1] based pastebin services, like http://paste.mate-desktop.org/

Inspired by [mpaste][2] from [mate-desktop][3], but I did not want to have Python dependency and wanted to add more features (file type detection).

## Installing

Just copy [pbin.sh](https://raw.githubusercontent.com/glensc/pbin/master/pbin.sh) to somewhere in your `$PATH`:

```
URL=https://raw.githubusercontent.com/glensc/pbin/master/pbin.sh
PBIN=~/.local/bin/pbin

wget $URL -O $PBIN || \
curl $URL $PBIN

chmod +x $PBIN
```

## Copyright

License: GPL v2

(c) 2014 Elan Ruusamäe <glen@pld-linux.org>


  [1]: https://github.com/claudehohl/Stikked
  [2]: https://github.com/mate-desktop/mate-desktop/blob/1.8/tools/mpaste
  [3]: http://mate-desktop.org/
