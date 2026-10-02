#!/bin/bash

SOURCE_DIR="/srv/music"
DEST_DIR="/mnt/music_backup"
DATE_FORMAT=$(date +"%y%m%d_%H%M%S")
ARCHIVE_NAME="music_${DATE_FORMAT}.tar.gz"
ARCHIVE_PATH="${DEST_DIR}/${ARCHIVE_NAME}"

tar -czf "$ARCHIVE_PATH" -C "$SOURCE_DIR" .

# verif compression
if [ $? -eq 0 ]; then
  echo "La sauvegarde a été réalisée avec succès : ${ARCHIVE_NAME}"
else
  echo "Erreur lors de la compression des fichiers."
  exit 1
fi
