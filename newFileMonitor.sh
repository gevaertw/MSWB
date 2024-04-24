#! /usr/bin/env bash
# https://stackoverflow.com/questions/13264529/how-to-find-if-there-are-new-files-in-a-directory-every-2-minutes-in-shell-scrip

TMP_DIR=./mount/tmp
DATAIN_DIR=./mount/datapipeline/datain
DATAOUT_DIR=./mount/datapipeline/dataout
FILELIST=./mount/tmp/filelist

[[ -f ${FILELIST} ]] || ls ${DATAIN_DIR} > ${FILELIST}

echo "Monitoring ${DATAIN_DIR} for new files."
while : ; do
    cur_files=$(ls -1 ${DATAIN_DIR})
    diff -u <(cat ${FILELIST}) <(echo $cur_files) || \
         { echo "Alert: ${DATAIN_DIR} changed $(date)" ;
           # Overwrite file list with the new one.
           echo $cur_files > ${FILELIST} ;
           # date > ${DATAOUT_DIR}/date_file.txt
           TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
           OUTFILE=${TMP_DIR}/Out_file_${TIMESTAMP}.txt
           touch $OUTFILE
           printf "New file was detected...\n" >> $OUTFILE
           cat ${FILELIST} >> $OUTFILE
           mv $OUTFILE $DATAOUT_DIR
           
         }

    echo "Waiting for changes."
    sleep $(expr 60 \* 1)
done
