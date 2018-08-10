#!/usr/bin/env bash




if [ -f '.DS_Store' ];
then
    rm '.DS_Store'
fi
directories=$(ls)
for dir in $directories
do
	echo "entering... $dir"

	if [[ ! $dir = *"EXP"* ]]; then
	    echo "skipping $dir as it is not a EXP directory..."
	    continue
	fi


	if ! cd "$dir"
    then
        echo "$dir not a directory or other error. Skipping..."
        continue
    fi

	if [ -f '.DS_Store' ];
    then
        rm '.DS_Store'
    fi

	if [ ! -d 'SOURCE/' ];
    then
        echo "SOURCE folder not found... skiping"
        continue
    fi

    if [ -f $dir'.csv' ]; then
        echo "Main file $dir'.csv' found, deleting..."
        rm "$dir"'.csv'
    fi

    #ener the source folder where the partial csv files are
    cd 'SOURCE'

	files=$(ls *.csv)
	first=true
	for file in $files
	do

        if [ "$file" = "$dir"'.csv' ]; then
            echo "Skipping main file..."
            continue
        fi


        #Does it has the HolderFirmware column?
        columns=$(head -n 1 $file)
        nrcolumns=$(head -n 1 $file | sed 's/[^;]//g' | wc -c)
        echo "File $file has $nrcolumns columns"
        index=1
        position=0
        IFS=";"
        for column in $columns
        do
            if [[ 'HolderFirmware' = $column ]]
            then
                echo "Column HolderFirmware found in position $index of $file"
                position=$index
            fi
            ((index++))
        done

        if [ ! $position = 0  ]; then
            echo "Creating cut file..."
            cut -d ";" -f -$(($position-1)),$(($position+1))- $file > $file'_cut'
            appendfile="$file"'_cut'
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
	done
	echo "Removing cut file ..."
	$(rm *_cut)
	mv "$dir"'.csv' '../'

	cd ".."
	cd ".."
done


