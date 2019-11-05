# test_dofiles
Simple script to test whether all Stata do-files in a folder can be run without error.


The script loops over each Stata do-file in a specified folder, and tries to run it. 
If running the file generates an error, the name of the file is logged, and its content copied in a specified subfolder.

WARNING: running do-files from untrusted sources could expose your computer to security risks.
