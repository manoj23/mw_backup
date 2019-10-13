mw_backup
=========

`mw_backup` is a simple script used to dump `mediawiki` database. To connect to
the database, it uses `LocalSettings.php`.

This script depends on: sh, date, and git.

## Example

```
#!/bin/sh

. /usr/local/bin/mw_backup.sh

mw_backup "/home/user/wwwdata/mediawiki/" "/home/user/wwwdata/mediawiki-backup/"
```
