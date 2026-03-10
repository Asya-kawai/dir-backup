
# Directory Backup Script

This script creates compressed backups (tar.gz) of a source directory into a destination directory, with safety checks and automatic rotation/deletion of old backups.

## Usage

```
bash dir_backup.sh <source-directory> <destination-directory> [--dry-run]
```

- `<source-directory>`: Directory to back up. You can use `.` for the current directory.
- `<destination-directory>`: Directory where the backup will be stored. You can use `.` for the current directory.
- `--dry-run`: (Optional) Show the commands that would be executed, without making any changes.

### Example

```
bash dir_backup.sh ~/Documents /mnt/backup
bash dir_backup.sh . . --dry-run
```

## Features

- Backs up the specified source directory as a compressed tar.gz archive in the destination directory.
- Excludes common cache, temporary, and large directories (e.g., Downloads, .cache, tmp*, etc.) from the backup.
- Prevents accidental backup of the root directory (`/`).
- Checks that both source and destination exist and are not the same.
- Sets file and directory permissions to 0700 (umask 077) for security.
- Supports a dry-run mode to preview commands without executing them.
- On the 1st day of each month, updates the access time of monthly backup files to help retain at least one monthly backup.
- Automatically deletes backup files older than 5 days that have not changed.

## How It Works

1. **Argument Validation**: Checks the number and validity of arguments. Exits with an error if arguments are missing or invalid.
2. **Path Handling**: Resolves `.` to the current directory and ensures full paths are used.
3. **Backup Creation**: Runs a `tar` command to create a compressed archive of the source directory, excluding certain patterns, and saves it in the destination directory with a timestamped filename.
4. **Monthly Rotation**: Updates the access time of backups created on the 1st of each month to help with monthly retention.
5. **Old Backup Cleanup**: Deletes backup files in the destination directory that are older than 5 days.

## Excluded Paths

The following directories and patterns are excluded from the backup to avoid unnecessary or large files:

- mnt
- Downloads
- tmp*
- work*
- timeshift
- .pyenv*
- .npm*
- .opam*
- .rbenv*
- .nvm*
- .texlive*
- .thumbnails
- .thunderbird*
- .cache*

## Exit Codes

- 0: Success
- 1: Destination directory not found
- 2: Source directory not found
- 3: Function argument error
- 4: Type error
- 5: Value error
- 255: Argument error

## Notes

- The script must be run with appropriate permissions to read the source and write to the destination.
- The backup filename format is `<source-directory-name>-<timestamp>.tar.gz`.
- The script is intended for local directory backup and not for remote or incremental backups.

## License

See LICENSE for details.
