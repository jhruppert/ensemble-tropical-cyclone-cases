 &time_control
 start_year                          = 2017, 2017,
 start_month                         = 09,   09,
 start_day                           = 14,   14,
 start_hour                          = 00,   00,
 start_minute                        = 00,   00,
 start_second                        = 00,   00,
 end_year                            = 2017, 2017,
 end_month                           = 09,   09,
 end_day                             = 18, 18, 20,   20,
 end_hour                            = 00,   00,
 end_minute                          = 00,   00,
 end_second                          = 00,   00,
 interval_seconds                    = 21600
 input_from_file                     = .true.,.true.,.true.,
 history_interval                    = 60,  60,   60,
 frames_per_outfile                  = 1, 1, 1,
 restart                             = .false.,
 restart_interval                    = 720,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 debug_level                         = 50
 iofields_filename = "var_extra_output","var_extra_output","var_extra_output"
 ignore_iofields_warning = .true.,
 io_form_auxinput4                   = 2
 auxinput4_inname                    = wrflowinp_d<domain>
 auxinput4_interval                  = 360, 360, 360,
 nwp_diagnostics                     = 1
 /

 &domains
 time_step                           = 60,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 reasonable_time_step_ratio          = 10,
 max_dom                             = 2,
 e_we                                = 390,  1201,
 e_sn                                = 240,  741,
! nproc_x = 30,
! nproc_y = 24,
 e_vert                              = 55,    55,    55,
 p_top_requested                     = 1000,
 num_metgrid_levels                  = 27,
 num_metgrid_soil_levels             = 4,
 dx                                  = 15000,  3000,
 dy                                  = 15000,  3000,
 grid_id                             = 1,     2,     3,
 parent_id                           = 0,     1,     2,
 i_parent_start                      = 1,    80,    82,
 j_parent_start                      = 1,    46,    75,
 parent_grid_ratio                   = 1,     5,     3,
 parent_time_step_ratio              = 1,     5,     3,
 feedback                            = 0,
 smooth_option                       = 0
 eta_levels                          = 1.0,0.9937543,0.9868422,0.9792133,0.9708155,0.9614043,0.9508600,0.9393044,0.9266810,0.9129300,0.8974756,0.8807267,0.8626400,0.8431811,0.8220488,0.7992166,0.7749856,0.7493867,0.7224600,0.6938300,0.6641278,0.6334766,0.6020043,0.5697655,0.5370866,0.5042589,0.4714566,0.4388600,0.4069244,0.3757167,0.3453699,0.3160099,0.2880100,0.2615300,0.2363878,0.2126211,0.1902600,0.1698822,0.1508933,0.1332600,0.1169478,0.1021622,0.0887900,0.0765289,0.0653245,0.0551200,0.0461755,0.0380366,0.0306533,0.0239756,0.0180644,0.0128267,0.0080922,0.0038267,0.0000000,
 /

 &physics
 cu_physics                          = 6, 0, 0,
 ra_lw_physics                       = 4, 4, 4,
 ra_sw_physics                       = 4, 4, 4,
 icloud                              = 1,
 mp_physics                          = 28,28
 bl_pbl_physics                      = 1, 1, 1,
 sf_sfclay_physics                   = 1, 1, 1,
 sf_surface_physics                  = 1, 1, 1,
 radt                                = 15,     3,
 bldt                                = 0,     0,     0,
 cudt                                = 5,     5,     5,
 num_soil_layers                     = 4,
 num_land_cat                        = 21,
 sf_urban_physics                    = 0,     0,     0,
 isftcflx                            = 1,
 do_radar_ref                        = 1,
 grav_settling      = 0,0,0,
 sst_update         = 1,
 sst_skin           = 1,
 isfflx             = 1,
 ifsnow             = 0,
 /

 &fdda
 /

 &dynamics
 hybrid_opt                          = 2, 
 w_damping                           = 0,
 diff_opt                            = 1,      1,      1,
 km_opt                              = 4,4,4,
 diff_6th_opt                        = 0,      0,      0,
 diff_6th_factor                     = 0.12,   0.12,   0.12,
 base_temp                           = 290.
 damp_opt                            = 3,
 zdamp                               = 10000., 10000., 10000.,
 dampcoef                            = 0.2,    0.2,    0.2
 khdif                               = 0,      0,      0,
 kvdif                               = 0,      0,      0,
 non_hydrostatic                     = .true., .true., .true.,
 moist_adv_opt                       = 1,      1,      1,     
 scalar_adv_opt                      = 1,      1,      1,     
 gwd_opt                             = 0, 0, 0,
 h_mom_adv_order      = 5,5,5,
 v_mom_adv_order      = 3,3,3,
 h_sca_adv_order      = 5,5,5,
 v_sca_adv_order      = 3,3,3,
 zadvect_implicit     = 1,
 w_crit_cfl           = 2.0,

 /

 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true., .false.,.false.,
 nested                              = .false., .true., .true.,
 /

 &grib2
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /
