#!/usr/bin/env bash

toremove="HolderFirmware ConsumerID ExternalConsumerID OperatorName OperatorIP"
IFS=' '
read -a removeColumns <<< $toremove
unset IFS

echo ${removeColumns[*]}

# check parameters
if [ $1 ]
then
    directories=($1)
else
    directories=$(ls)
fi

for dir in $directories
do

    #Go into directory or else skip it
	if ! cd "$dir"
    then
        continue
    fi

    files=$(ls *.csv);
	for file in $files
	do

        #Skip the main file
        if [[ $file == $dir'.csv' ]]; then
            echo "Skipping main file..."
            continue
        fi

        if [[  $file == *'_EXP_'* ]]
        then
            echo "----------------------"
            echo "Reviewing file $file"
            echo ""
            #Does it has the HolderFirmware column?
            columns=$(head -n 1 $file)
            nrcolumns=$(head -n 1 $file | sed 's/[^;]//g' | wc -c)
            index=1

            IFS=';'
            read -a columnsarray <<< $columns
            unset IFS

            for  column in $columnsarray
            do
                for removeColumn in ${removeColumns[*]}
                do
                    #  echo "is column $column equal to removecolumn:$removeColumn ?"
                    if [[ $column == $removeColumn ]]
                    then
                        echo "Column $column found in position $index"
                    fi
                done
                ((index++))

            done
	    fi


	done
	cd '..'
done
