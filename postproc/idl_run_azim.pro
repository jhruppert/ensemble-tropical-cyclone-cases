
spawn,'date',date_return1

add_dir

;tcname='maria' ; storm name
tcname='haiyan' ; storm name
case_str='ctl' ; test directory
case_str='haiyan' ; test directory

ensmemb=20 ; Set ensemble member
iv_calc=12 ; Set variable to process

run_enstc_calc_azim, ensmemb, iv_calc, tcname, case_dir

print,date_return1
spawn,'date'


