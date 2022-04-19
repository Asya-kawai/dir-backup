# Dir backup.

Dir backup creates(copis) source directories to destination directory in recursive.

# Usage

```
bash dir_backup.sh source-directory destination-directory
```

You can check execution command when use '--dry-run'.

```
bash dir_backup.sh source-directory destination-directory --dry-run
```

# Features

* Can set dot('.') as the source-directory.
* Can set dot('.') as the destination-directory.
* Block and return an error when source-directory is '/'.
* Block and return an error when source-directory or destination-directory is not found.
* Update 1st day of each month to save and can restore before at least one month.
* Delete backup files automatically when you did not access in 5days.
