
# format time string for wrf file names
def wrf_time_string(t):
  # tmp=stringtochar(t)
  tstr=t[0:3]+"-"+t[4:5]+"-"+t[6:7]+"_" \
      +t[8:9]+":"+t[10:11]+":00"
  return(tstr)

t0="201311010000"
wrftim = wrf_time_string(t0)
print(wrftim)

# advance time: usage: t = ccyymmddhhii, dt = difference in minutes
# def advance_time(t,dt):
#   tmp=stringtochar(t)
#   ccyy=stringtointeger(chartostring(tmp(0:3)))
#   mm=stringtointeger(chartostring(tmp(4:5)))
#   dd=stringtointeger(chartostring(tmp(6:7)))
#   hh=stringtointeger(chartostring(tmp(8:9)))
#   ii=stringtointeger(chartostring(tmp(10:11)))
#   time=ut_inv_calendar(ccyy,mm,dd,hh,ii,0,"minutes since 1900-01-01 00:00:00",0)
#   time=time+dt
#   tout=ut_calendar(time,0)
#   t1=sprinti("%4.4i",floattointeger(tout(0,0)))
#   t1=t1+sprinti("%2.2i",floattointeger(tout(0,1)))
#   t1=t1+sprinti("%2.2i",floattointeger(tout(0,2)))
#   t1=t1+sprinti("%2.2i",floattointeger(tout(0,3)))
#   t1=t1+sprinti("%2.2i",floattointeger(tout(0,4)))
#   return(t1)
