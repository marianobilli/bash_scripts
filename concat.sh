#!/usr/bin/env bash

toremove="HolderFirmware ConsumerID ExternalConsumerID OperatorName OperatorIP"
IFS=' '
read -a removeColumns <<< $toremove
unset IFS

sourceFolder=true
for option in "$@"
do

    if [[ $option = '--no-source-folder' ]]
    then
        sourceFolder=false
    fi

done

if [ -f '.DS_Store' ];
then
    rm '.DS_Store'
fi
directories=$(ls)
for dir in $directories
do
	echo "from $(pwd) entering... $dir"

	if ! cd "$dir"
    then
        echo "$dir not a directory or other error. Skipping..."
        continue
    fi

	if [ -f '.DS_Store' ];
    then
        rm '.DS_Store'
    fi

	if [ -f $dir'.csv' ]; then
	        echo "A main file exists..."
	        isFirst=false
	else
	        isFirst=true
	fi


	if [ ! -d 'SOURCE' ] && [ $sourceFolder = true ] ; then
	    mkdir 'SOURCE'
	fi

	files=$(ls *.csv);

	for file in $files
	do
        # To avoid appending the main file to itself
        if [[ $file == $dir'.csv' ]]; then
            echo "Skipping main file..."
            continue
        fi

        if [[  $file == *'_EXP_'* ]]
        then

            #number of columns in the file
            nrcolumns=$(head -n 1 $file | sed 's/[^;]//g' | wc -c)
            echo "File $file has $nrcolumns"

            #set array of file columns
            columns=$(head -n 1 $file)
            IFS=';'
            read -a columnsarray <<< $columns
            unset IFS

            removeColumnFound=false
            index=1 #to track the position of the found column
            for  column in $columnsarray
            do
                for removeColumn in ${removeColumns[*]}
                do
                    if [[ $column == $removeColumn ]]
                    then
                        removeColumnFound=true
                        echo "Column $column found in position $index"
                        cuttedFile=$file'_cut'
                        tempFile=$file'_cuttemp'

                        if [ -f $cuttedFile ] #did I created already a cut file?
                        then
                            #I will continue cutting the cutted file so I make it a temp file
                            mv $cuttedFile $tempFile
                            fileToCut=$tempFile

                        else
                            fileToCut=$file
                        fi

                        if [ $index = 1 ]
                        then
                            cut -d ";" -f $(($index+1))- $fileToCut > $cuttedFile
                        else
                            cut -d ";" -f -$(($index-1)),$(($index+1))- $fileToCut > $cuttedFile
                        fi

                        if [ -f $tempFile ]; then  rm $tempFile ; fi ;

                        nrcolumnsCutFile=$(head -n 1 $cuttedFile | sed 's/[^;]//g' | wc -c)
                        echo "Cutted file $cuttedFile has $nrcolumnsCutFile"

                        #I need to subtract a number as I am removing one column in the cut file
                        ((index--))
                    fi
                done
                ((index++))

            done

            if [ $removeColumnFound ]; then
                appendfile=$file'_cut'
            else
                appendfile=$file
            fi
        else
            appendfile=$file
	    fi

		#append each file to a new csv file
		if [ "$isFirst" = false ]; then
			#use tail to remove the header line
			echo "Appending $appendfile to $dir.csv"
			tail -n +2 "$appendfile" >> "$dir"'.csv'
		else
			#use cat because is the first
			echo "Copying $appendfile to $dir.csv"
			cat "$appendfile" > "$dir"'.csv'
			isFirst=false
		fi

        if [ $sourceFolder = true ]
        then
			mv "$file" 'SOURCE'
		else
		    rm $file
		fi

		if [[ $appendfile = *'_cut'* ]]
		then
			echo "Removing cut file..."
			rm $appendfile
		fi
	done
	cd '..'
done
