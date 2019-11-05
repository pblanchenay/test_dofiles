/* ==========================================================
	Script to test whether a series of do-files 
	can run without generating errors.
	
	I use this to test students' assignment do-files.
	
	It loops over all do-files in a folder,
	can perform some replacement (eg replacing a custom 
	working directory with your own).
	
	If a file generates an error, it is copied in a subfolder, 
	and lists it in a file error_lists.txt
	
============================================================= */


/* ====== PARAMETERS TO CHANGE ====== */
local wd "myworkingdirectoyr" // Working directory (where the script is)
local dofilessub "do-files" // where the do-files to test are
local errorsubfolder "errors" // where error_lists and error files will be copied

/* ====== EXECUTION STARTS HERE ====== */
file close _all
set more off
set graphics off // avoid generating graphs 
cd "`wd'"
shell mkdir "`dofilessub'/`errorsubfolder'/"

file open errorfile using `"`dofilessub'/`errorsubfolder'/errors_list.txt"', write replace text // open the connection to the error list

local filenum = 0 // initialize file number
local files : dir "`dofilessub'" files "*.do" // get list of do-files in folder

// Loop over each submission
foreach file in `files' {
	display as text `"`dofilessub'/`file' ..."'  _continue
	
	local filenum = `filenum' +1
  
	tempname `filenum'hr // the file being read
	tempname `filenum'hw // the file being written
	
	quietly file open ``filenum'hr' using `"`dofilessub'/`file'"', read
	quietly file open ``filenum'hw' using `"`dofilessub'/`errorsubfolder'/`file'"', write text replace
		
	local linenum = 0
	file read ``filenum'hr' line // read first line
	while r(eof)==0 {
			local linenum = `linenum' + 1
			// Change working directory // Loop over each line, if it contains cd, replace with my own, other copy as is
			if(strpos(`"`line'"',"cd ")) {
				file write ``filenum'hw' `"cd "`wd'"  // replaced automatically by script"' _n
			}
			// else just copy the line as is
			else {
				file write ``filenum'hw' `"  `macval(line)'"' _n
			}		
			
			file read ``filenum'hr' line // read next line
	}
	quietly file close ``filenum'hr'
	quietly file close ``filenum'hw'
	
	display   " PROCESSED."
	
	display "Trying to run `file' ..." _continue
	capture run `"`dofilessub'/`errorsubfolder'/`file'"'
	
	
	if(_rc) { // If there is an error, record it and keep erroneous file
		display as error "ERROR." 
		file write errorfile `"`file' : error code `=_rc'"' _n // write this error to the errors_list.txt file
	}
	else { // Otherwise, erase file and move on.
		display as result "Done."
		erase `"`dofilessub'/`errorsubfolder'/`file'"' 
	}
	



}
// end of loop on files 
file close _all
set graphics on
