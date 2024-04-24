#! /usr/bin/env bash
# https://stackoverflow.com/questions/13264529/how-to-find-if-there-are-new-files-in-a-directory-every-2-minutes-in-shell-scrip

TMP_DIR=./mount/tmp
DATAIN_DIR=./mount/datapipeline/datain
DATAOUT_DIR=./mount/datapipeline/dataout
FILELIST=./mount/tmp/filelist


cur_files=$(ls ${DATAIN_DIR})
echo $cur_files > ${FILELIST}

echo "Monitoring ${DATAIN_DIR} for new files."
while : ; do
    cur_files=$(ls ${DATAIN_DIR})
    
    if diff --brief --ignore-all-space <(cat ${FILELIST}) <(echo $cur_files) >/dev/null ; then
        printf "$(date): No changes detected in ${DATAIN_DIR}.\n"
        :
    else
        diff -u <(cat ${FILELIST}) <(echo $cur_files) || \
            { printf "$(date): Changes detected in ${DATAIN_DIR}. \n" ;
            # Overwrite file list with the new one.
            echo $cur_files > ${FILELIST} ;
            TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
            OUTFILE=${TMP_DIR}/Out_file_${TIMESTAMP}.txt
            touch $OUTFILE
            printf "Changes were detected, list of files: \n" >> $OUTFILE
            cat ${FILELIST} >> $OUTFILE
            mv $OUTFILE $DATAOUT_DIR
            }
    fi

    sleep $(expr 60 \* 1)
done
