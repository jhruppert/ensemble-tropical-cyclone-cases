# Function to process a bulk set of variables from WRF output
# 
# Main reason for this step of post-processing is to go from
# single-time-step files to individual variable files with full
# time series.

def process_wrf(t0,npd,nd,testname):

    # TIME SPECS
    # npd=24 # N-per day
    # nd=7 # Setdays
    # t0="201311010000" ; Start time
    stepnn=1440/nd # read time step (minutes)

    # RETRIEVE DOMAIN SPECS
    time=advance_time(t0,0)
    a=addfile(dir+"/wrfout_"+d+"_"+wrf_time_string(time),"r")
    dims=getfiledimsizes(a)
    nx=dims(2)
    ny=dims(3)
    nz=dims(4)
