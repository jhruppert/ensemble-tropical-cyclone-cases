load "util.ncl"

; ncl process_wrf.ncl t=$t v=$v

;; t - test name
; v - variable


;-----EXPERIMENTS AND DIRECTORIES----------------------

;  testname=(/"ctl","icloud0"/)
  dir="../output" ; project directory
  outfiledir=dir+"/post/"+d+"/" ; output file location

  ;TIME SPECS
    npd=24
    nd=6 ; Setdays
    t0="201709140000" ; Start time
    stepnn=60 ; read time step (minutes)

  ;RETRIEVE DOMAIN SPECS
    time=advance_time(t0,0)
    a=addfile(dir+"/wrfout_"+d+"_"+wrf_time_string(time),"r")
    dims=getfiledimsizes(a)
    nx=dims(2)
    ny=dims(3)
    nz=dims(4)

;  if (testname(t).eq."30d") then
;  else if (testname(t).eq."largexa") then
;    nx=479
;  else if (testname(t).eq."largexb") then
;    nx=718
;  end if
;  end if
;  end if

  nt=tointeger(nd*npd)+1


;-----VARIABLE AND PRES-INTERP SPECS----------------------


dz=100
;plevel=ispan(1000,50,25)
plevel=ispan(1000,100,dz)

plev_write=tofloat(plevel)

np=dimsizes(plevel)

;           0       1        2     3     4      5     6   7     8     9   10  11  12  13  14     15      16       17      18     19      20         21       22        23  24   25     26       27          28       29     30     31      32         33       34      35      36      37      38       39       40      41       42      43      44      45       46       47       48      49      50       51
varname=(/"OLR","rainrate","U10","V10","PSFC","TSK","T2","Q2","HFX","LH","PW","U","V","W","T","QVAPOR","QCLOUD","QRAIN","QICE","QSNOW","QGRAUP","RTHRATLW","RTHRATSW","Z","ZB","SLP","OLRC","RTHRATLWC","RTHRATSWC","AVOR","GLW","GLWC","RAINNC","H_DIABATIC","SST","RAINC","SWUPT","SWUPTC","SWDNT","SWDNTC","SWUPB","SWUPBC","SWDNB","SWDNBC","LWUPT","LWUPTC","LWDNT","LWDNTC","LWUPB","LWUPBC","LWDNB","LWDNBC"/)
nlvs   =(/    1,         1,    1,    1,     1,    1,   1,   1,    1,   1,   1, np, np, np, np,      np,      np,     np,    np,     np,      np,        np,        np, np,  np,    1,     1,        np,    np,          np,    1,     1,       1,          np,    1,      1,      1,       1,      1,       1,      1,       1,      1,       1,      1,       1,      1,       1,      1,       1,      1,       1/)
; number of vertical levels

if(varname(v).eq."ZB") then ; base-state height
  nt=1
end if

fileout=outfiledir+varname(v)+".nc"
print(fileout)

system("rm -f "+fileout)
setfileoption("nc","Format","NetCDF4") ; force NCDF4 format (much faster, capable of large datasets)
b=addfile(fileout,"c")
var=new((/nt,nlvs(v),ny,nx/),"float")


;-----RUN LOOP----------------------


;  loop over time and process wrfout files into intermediate nc files
;t0="201110010000"
do n=0,nt-1
;do n=0,0;nt-1,nt-1
  time=advance_time(t0,stepnn*n)
  print(time)
	a=addfile(dir+"/wrfout_"+d+"_"+wrf_time_string(time),"r");+"_"+sprinti("%3.3i",m),"r")       ; original wrfout files
  p=a->P(0,:,:,:)+a->PB(0,:,:,:)
  if(varname(v).eq."U") then
    tmp=0.5*(a->U(0,:,:,0:nx-1)+a->U(0,:,:,1:nx))
  else if(varname(v).eq."V") then
    tmp=0.5*(a->V(0,:,0:ny-1,:)+a->V(0,:,1:ny,:))
  else if(varname(v).eq."W") then
    tmp=0.5*(a->W(0,0:nz-1,:,:)+a->W(0,1:nz,:,:))
  else if(varname(v).eq."T") then
    tmp=wrf_tk(p,a->T(0,:,:,:)+300)
  else if(varname(v).eq."Z") then
    tmp=0.5*(a->PH(0,0:nz-1,:,:)+a->PH(0,1:nz,:,:))/9.81
  else if(varname(v).eq."ZB") then
    tmp=0.5*(a->PHB(0,0:nz-1,:,:)+a->PHB(0,1:nz,:,:))/9.81
  else if(varname(v).eq."rainrate") then
    tmp=a->RAINNC(0,:,:)
  else if(varname(v).eq."PW") then
    tmp=rm_single_dims(wrf_user_getvar(a,"pw",-1))
  else if(varname(v).eq."SLP") then
    tmp=rm_single_dims(wrf_user_getvar(a,"slp",-1))
  else if(varname(v).eq."AVOR") then
    tmp=rm_single_dims(wrf_user_getvar(a,"avo",-1))
  else if(varname(v).eq."RAINNC") then
    tmp=a->RAINNC(0,:,:)+a->RAINC(0,:,:)+a->RAINSH(0,:,:)
  else
    if (nlvs(v).gt.1) then
      tmp=a->$varname(v)$(0,:,:,:)
    else
      tmp=a->$varname(v)$(0,:,:)
    end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  if (nlvs(v).gt.1) then
    var(n,:,:,:)=linint1_n(p,tmp,False,plevel*100,0,0)    ; if 3D variable, perform vertical interpolation to pressure levels
  else
    var(n,0,:,:)=tmp
  end if
end do

;INTERPOLATE NANS ACROSS Z
  var=linmsg_n(var,-1,1)
;INTERPOLATE NANS ACROSS TIME
  var=linmsg_n(var,-1,0)

;CALCULATE RAIN RATE (CENTERED DIFFERENCE)
  if(varname(v).eq."rainrate") then
    newv=var
    var(:,:,:,:)=0.0
    do it=1,nt-2
      var(it,0,:,:)=(newv(it+1,0,:,:)-newv(it-1,0,:,:))
    end do
    var=var*(npd*0.5) ; mm / time step --> mm / d
  end if

var!0="time"
var!1="level"
var!2="lat"
var!3="lon"
if (nlvs(v).gt.1) then
  plev_write!0="level"
  b->pres=plev_write
end if
b->$varname(v)$=var

exit
