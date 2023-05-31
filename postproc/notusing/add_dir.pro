pro add_dir

idldir='/home1/06040/tg853394/idl/code'
!PATH=!PATH+':'+idldir

;ADD CODE DIRECTORIES TO PATH
  dir=idldir+'/*/'
  spawn,'ls -d '+dir+' | grep -v figure',dirlist,err
  while dirlist[0] ne '' do begin
    if (size(dirlist,/dimensions))[0] gt 1 then $
      add=strjoin(dirlist,':') $
    else $
      add=dirlist[0]
    !PATH+=':'+add
    dir+='*/'
    spawn,'ls -d '+dir+' | grep -v figure',dirlist,err
  endwhile

end
