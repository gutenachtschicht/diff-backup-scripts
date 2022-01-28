# diff-backup-scripts
A very slow growing collection of scripts to perform differential backups and restore from Windows command line interfaces.

First you do a full backup and then you do differntial backups. To restore you start to copy the full backup first an then you copy one differential backup after the other from oldest to the latest you want to restore into the full backup folder, allowing overwriting existing files.

---

A differential backup on file level makes sense if your data and work is stored in many little chunks.

As soon as your backup includes a large blob file, e.g. a huge database file or an image that is changed with each access, this way of differential backup does not pay off, these files you should exclude and apply a different strategy!

A differential backup does not consider files getting deleted, it will not recognize deletion so that deleted files will re-appear. If the software or data behaves different on presence of a deleted file, then this differential backup strategy might cause problems on restore.

NEVER TRUST A BACKUP THAT YOU HAVE NOT RESTORED ONCE.