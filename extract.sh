#!/bin/bash

zipfiles=$(ls *.zip)

for zipfile in $zipfiles
do

	echo "--------------------------------------------"
	if [ -f '.DS_Store' ] ;then
	    rm '.DS_Store'
	fi
	unzip "$zipfile"
	xlsfiles=$(ls *.xlsx)

	for xlsfile in $xlsfiles
	do
		
		echo "xls file: $xlsfile"
		report=$(echo $xlsfile | cut -d _ -f2)
		country=$(echo $xlsfile | cut -d _ -f3)
		data=$(echo $xlsfile | cut -d _ -f4 | tr '[:lower:]' '[:upper:]')


		echo "report:"$report" | country:"$country" | data:"$data

		if [ "$data" = "EXPERIENCE" ]; then
			data="EXP"
		fi

		table=$country'_'$report'_'$data
		echo "table: $table"


		#identify date ranges

		if [ "$data" = 'HOLDER' ] || [ "$data" = 'CHARGER' ];then

            text=$(echo $xlsfile | cut -d _ -f6)
            if [ "$text" = 'from' ];then
                from=$(echo $xlsfile | cut -d _ -f7)

                # ASSUMPTION, if there is a FROM then there is a TO
                to=$(echo $xlsfile | cut -d _ -f9)
                csvfilename=$table'_from_'"$from"'_to_'"$to"'.csv'
            else
                if [ "$text" = 'to' ];then
                    to=$(echo $xlsfile | cut -d _ -f7)
                    csvfilename=$table'_to_'"$to"'.csv'
                else
                    echo "--- ERROR:  Cannot deterimne range selection dates"
                    rm "$xlsfile"
                    continue
                fi
            fi
		else
            text=$(echo $xlsfile | cut -d _ -f5)
            if [ "$text" = 'from' ];then
                from=$(echo $xlsfile | cut -d _ -f6)

                # ASSUMPTION, if there is a FROM then there is a TO
                to=$(echo $xlsfile | cut -d _ -f8)
                csvfilename=$table'_from_'"$from"'_to_'"$to"'.csv'
            else
                if [ "$text" = 'to' ];then
                    to=$(echo $xlsfile | cut -d _ -f6)
                    csvfilename=$table'_to_'"$to"'.csv'
                else
                    echo "--- ERROR:  Cannot deterimne range selection dates"
                    rm "$xlsfile"
                    continue
                fi
            fi
		fi

		echo "csv filename: $csvfilename"

  		#if folder does not exist then create it
  		if [ ! -d "$table" ]; then
		    mkdir "$table"
		fi

		$(ssconvert -S --export-options 'separator=;' --export-type=Gnumeric_stf:stf_assistant "$xlsfile" "$csvfilename")
		echo "deleting xlsx file...."
		rm "$xlsfile"


		csvfiles=$(ls *.csv.*)
		echo "Renaming extensions of csv files"
		for csvfile in $csvfiles
		do
		    filename=$(echo $csvfile | cut -d . -f1)
            filenumber=$(echo $csvfile | cut -d . -f3)

            if [ "$filenumber" = '0' ];then
                echo "deleting .0 file"
                rm "$csvfile"
                continue
            fi
            mv "$csvfile" "$table"'/'"$filename"'_'"$filenumber"'.csv'
		done

	done
done
