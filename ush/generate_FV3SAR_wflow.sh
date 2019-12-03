#!/bin/bash -l
#
#-----------------------------------------------------------------------
#
# This file defines and then calls a function that sets up a forecast
# experiment and creates a workflow (according to the parameters speci-
# fied in the configuration file; see instructions).
#
#-----------------------------------------------------------------------
#
function generate_FV3SAR_wflow() {
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
local scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
local scrfunc_fn=$( basename "${scrfunc_fp}" )
local scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Get the name of this function.
#
#-----------------------------------------------------------------------
#
local func_name="${FUNCNAME[0]}"
#
#-----------------------------------------------------------------------
#
# Set directories.
#
#-----------------------------------------------------------------------
#
ushdir="${scrfunc_dir}"
#
#-----------------------------------------------------------------------
#
# Source function definition files.
#
#-----------------------------------------------------------------------
#
. $ushdir/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Load modules.
#
#-----------------------------------------------------------------------
#
module purge
# These need to be made machine-dependent.  The following work only on
# Hera.
module load intel/19.0.4.243
module load netcdf/4.7.0
#
#-----------------------------------------------------------------------
#
# Source the setup script.  Note that this in turn sources the configu-
# ration file/script (config.sh) in the current directory.  It also cre-
# ates the run and work directories, the INPUT and RESTART subdirecto-
# ries under the run directory, and a variable definitions file/script
# in the run directory.  The latter gets sources by each of the scripts
# that run the various workflow tasks.
#
#-----------------------------------------------------------------------
#
. $ushdir/setup.sh
#
#-----------------------------------------------------------------------
#
# Set the full paths to the template and actual workflow xml files.  The
# actual workflow xml will be placed in the run directory and then used
# by rocoto to run the workflow.
#
#-----------------------------------------------------------------------
#
TEMPLATE_XML_FP="${TEMPLATE_DIR}/${WFLOW_XML_FN}"
WFLOW_XML_FP="$EXPTDIR/${WFLOW_XML_FN}"
#
#-----------------------------------------------------------------------
#
# Copy the xml template file to the run directory.
#
#-----------------------------------------------------------------------
#
cp_vrfy ${TEMPLATE_XML_FP} ${WFLOW_XML_FP}
#
#-----------------------------------------------------------------------
#
# Set local variables that will be used later below to replace place-
# holder values in the workflow xml file.
#
#-----------------------------------------------------------------------
#
PROC_RUN_FCST="${NUM_NODES}:ppn=${NCORES_PER_NODE}"

FHR=( $( seq 0 1 ${FCST_LEN_HRS} ) )
i=0
FHR_STR=$( printf "%02d" "${FHR[i]}" )
numel=${#FHR[@]}
for i in $(seq 1 $(($numel-1)) ); do
  hour=$( printf "%02d" "${FHR[i]}" )
  FHR_STR="${FHR_STR} $hour"
done
FHR="${FHR_STR}"
#
#-----------------------------------------------------------------------
#
# Fill in the xml file with parameter values that are either specified
# in the configuration file/script (config.sh) or set in the setup
# script sourced above.
#
#-----------------------------------------------------------------------
#
CDATE_generic="@Y@m@d@H"
if [ "${RUN_ENVIR}" = "nco" ]; then
  CYCLE_DIR="$STMP/tmpnwprd/${PREDEF_GRID_NAME}_${CDATE_generic}"
else
  CYCLE_DIR="$EXPTDIR/${CDATE_generic}"
fi

set_file_param "${WFLOW_XML_FP}" "GLOBAL_VAR_DEFNS_FP" "${GLOBAL_VAR_DEFNS_FP}"
set_file_param "${WFLOW_XML_FP}" "CYCLE_DIR" "${CYCLE_DIR}"
set_file_param "${WFLOW_XML_FP}" "ACCOUNT" "$ACCOUNT"
set_file_param "${WFLOW_XML_FP}" "SCHED" "$SCHED"
set_file_param "${WFLOW_XML_FP}" "QUEUE_DEFAULT" "${QUEUE_DEFAULT}"
set_file_param "${WFLOW_XML_FP}" "QUEUE_HPSS" "${QUEUE_HPSS}"
set_file_param "${WFLOW_XML_FP}" "QUEUE_FCST" "${QUEUE_FCST}"
set_file_param "${WFLOW_XML_FP}" "USHDIR" "$USHDIR"
set_file_param "${WFLOW_XML_FP}" "JOBSDIR" "$JOBSDIR"
set_file_param "${WFLOW_XML_FP}" "EXPTDIR" "$EXPTDIR"
set_file_param "${WFLOW_XML_FP}" "LOGDIR" "$LOGDIR"
set_file_param "${WFLOW_XML_FP}" "EXTRN_MDL_NAME_ICS" "${EXTRN_MDL_NAME_ICS}"
set_file_param "${WFLOW_XML_FP}" "EXTRN_MDL_NAME_LBCS" "${EXTRN_MDL_NAME_LBCS}"
set_file_param "${WFLOW_XML_FP}" "EXTRN_MDL_FILES_SYSBASEDIR_ICS" "${EXTRN_MDL_FILES_SYSBASEDIR_ICS}"
set_file_param "${WFLOW_XML_FP}" "EXTRN_MDL_FILES_SYSBASEDIR_LBCS" "${EXTRN_MDL_FILES_SYSBASEDIR_LBCS}"
set_file_param "${WFLOW_XML_FP}" "PROC_RUN_FCST" "${PROC_RUN_FCST}"
set_file_param "${WFLOW_XML_FP}" "DATE_FIRST_CYCL" "${DATE_FIRST_CYCL}"
set_file_param "${WFLOW_XML_FP}" "DATE_LAST_CYCL" "${DATE_LAST_CYCL}"
set_file_param "${WFLOW_XML_FP}" "YYYY_FIRST_CYCL" "${YYYY_FIRST_CYCL}"
set_file_param "${WFLOW_XML_FP}" "MM_FIRST_CYCL" "${MM_FIRST_CYCL}"
set_file_param "${WFLOW_XML_FP}" "DD_FIRST_CYCL" "${DD_FIRST_CYCL}"
set_file_param "${WFLOW_XML_FP}" "HH_FIRST_CYCL" "${HH_FIRST_CYCL}"
set_file_param "${WFLOW_XML_FP}" "FHR" "$FHR"
set_file_param "${WFLOW_XML_FP}" "RUN_TASK_MAKE_GRID" "${RUN_TASK_MAKE_GRID}"
set_file_param "${WFLOW_XML_FP}" "RUN_TASK_MAKE_OROG" "${RUN_TASK_MAKE_OROG}"
set_file_param "${WFLOW_XML_FP}" "RUN_TASK_MAKE_SFC_CLIMO" "${RUN_TASK_MAKE_SFC_CLIMO}"
#
#-----------------------------------------------------------------------
#
# Extract from CDATE the starting year, month, day, and hour of the
# forecast.  These are needed below for various operations.
#
#-----------------------------------------------------------------------
#
YYYY_FIRST_CYCL=${DATE_FIRST_CYCL:0:4}
MM_FIRST_CYCL=${DATE_FIRST_CYCL:4:2}
DD_FIRST_CYCL=${DATE_FIRST_CYCL:6:2}
HH_FIRST_CYCL=${CYCL_HRS[0]}
#
#-----------------------------------------------------------------------
#
# Replace the dummy line in the XML defining a generic cycle hour with
# one line per cycle hour containing actual values.
#
#-----------------------------------------------------------------------
#
regex_search="(^\s*<cycledef\s+group=\"at_)(CC)(Z\">)(\&DATE_FIRST_CYCL;)(CC00)(\s+)(\&DATE_LAST_CYCL;)(CC00)(.*</cycledef>)(.*)"
i=0
for cycl in "${CYCL_HRS[@]}"; do
  regex_replace="\1${cycl}\3\4${cycl}00 \7${cycl}00\9"
  crnt_line=$( sed -n -r -e "s%${regex_search}%${regex_replace}%p" "${WFLOW_XML_FP}" )
  if [ "$i" -eq "0" ]; then
    all_cycledefs="${crnt_line}"
  else
    all_cycledefs=$( printf "%s\n%s" "${all_cycledefs}" "${crnt_line}" )
  fi
  i=$((i+1))
done
#
# Replace all actual newlines in the variable all_cycledefs with back-
# slash-n's.  This is needed in order for the sed command below to work
# properly (i.e. to avoid it failing with an "unterminated `s' command"
# message).
#
all_cycledefs=${all_cycledefs//$'\n'/\\n}
#
# Replace all ampersands in the variable all_cycledefs with backslash-
# ampersands.  This is needed because the ampersand has a special mean-
# ing when it appears in the replacement string (here named regex_re-
# place) and thus must be escaped.
#
all_cycledefs=${all_cycledefs//&/\\\&}
#
# Perform the subsutitution.
#
sed -i -r -e "s|${regex_search}|${all_cycledefs}|g" "${WFLOW_XML_FP}"
#
#-----------------------------------------------------------------------
#
# Save the current shell options, turn off the xtrace option, load the
# rocoto module, then restore the original shell options.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set +x; } > /dev/null 2>&1
module load rocoto/1.3.1
{ restore_shell_opts; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# For convenience, print out the commands that needs to be issued on the 
# command line in order to launch the workflow and to check its status.  
# Also, print out the command that should be placed in the user's cron-
# tab in order for the workflow to be continually resubmitted.
#
#-----------------------------------------------------------------------
#
WFLOW_DB_FN="${WFLOW_XML_FN%.xml}.db"
load_rocoto_cmd="module load rocoto/1.3.1"
rocotorun_cmd="rocotorun -w ${WFLOW_XML_FN} -d ${WFLOW_DB_FN} -v 10"
rocotostat_cmd="rocotostat -w ${WFLOW_XML_FN} -d ${WFLOW_DB_FN} -v 10"

print_info_msg "
========================================================================
========================================================================

Workflow generation completed.

========================================================================
========================================================================

The experiment directory is:

  > EXPTDIR=\"$EXPTDIR\"

To launch the workflow, first ensure that you have a compatible version
of rocoto loaded.  For example, on theia, the following version has been
tested and works:

  > ${load_rocoto_cmd}

(Later versions may also work but have not been tested.)  To launch the 
workflow, change location to the experiment directory (EXPTDIR) and is-
sue the rocotrun command, as follows:

  > cd $EXPTDIR
  > ${rocotorun_cmd}

To check on the status of the workflow, issue the rocotostat command 
(also from the experiment directory):

  > ${rocotostat_cmd}

Note that:

1) The rocotorun command must be issued after the completion of each 
   task in the workflow in order for the workflow to submit the next 
   task(s) to the queue.

2) In order for the output of the rocotostat command to be up-to-date,
   the rocotorun command must be issued immediately before the rocoto-
   stat command.

For automatic resubmission of the workflow (say every 3 minutes), the 
following line can be added to the user's crontab (use \"crontab -e\" to
edit the cron table): 

*/3 * * * * cd $EXPTDIR && $rocotorun_cmd

Done.
"




#
#-----------------------------------------------------------------------
#
# Make sure that the correct ozone production/loss fixed file is speci-
# fied in the array FIXam_FILES_SYSDIR.  There should be two such files
# on disk in the system directory specified in FIXgsm.  They are named
#
#   ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77
#
# and
#
#   global_o3prdlos.f77
#
# The first should be used with the 2015 ozone parameterization, while
# the second should be used with the more recent ozone parameterization
# (referred to here as the after-2015 parameterization).
#
# Which of these should be used depends on the specified physics suite
# (CCPP_PHYS_SUITE).  The GFS physics suite uses the after-2015 parame-
# terization, while the GSD physics suite uses the 2015 parameteriza-
# tion.  Thus, we must ensure that the ozone production/loss fixed file
# listed in the array FIXam_FILES_SYSDIR is the correct one for the gi-
# ven physics suite.  We do this below as follows.
#
# First, note that FIXam_FILES_SYSDIR should contain the name of exactly
# one of the ozone production/loss fixed files listed above.  We verify
# this by trying to obtain the indices of the elements of FIXam_FILES_-
# SYSDIR that contain the two files.  One of these indices should not
# exist while the other one should.  If the 2015 file is the one that is
# found in FIXam_FILES_SYSDIR, then if we're using GFS physics, we 
# change that element in FIXam_FILES_SYSDIR to the name of the after-
# 2015 file.  Similarly, if the after-2015 file is the one that is found
# in FIXam_FILES_SYSDIR, then if we're using GSD physics, we change that
# element in FIXam_FILES_SYSDIR to the name of the 2015 file.  If 
# neither file or more than one ozone production/loss file is found in
# FIXam_FILES_SYSDIR, we print out an error message and exit.
#
#-----------------------------------------------------------------------
#
ozphys_2015_fn="ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77"
indx_ozphys_2015=$( get_elem_inds "FIXam_FILES_SYSDIR" "${ozphys_2015_fn}" )
read -a indx_ozphys_2015 <<< ${indx_ozphys_2015}
num_files_ozphys_2015=${#indx_ozphys_2015[@]}

ozphys_after2015_fn="global_o3prdlos.f77"
indx_ozphys_after2015=$( get_elem_inds "FIXam_FILES_SYSDIR" "${ozphys_after2015_fn}" )
read -a indx_ozphys_after2015 <<< ${indx_ozphys_after2015}
num_files_ozphys_after2015=${#indx_ozphys_after2015[@]}

if [ ${num_files_ozphys_2015} -eq 1 ] && \
   [ ${num_files_ozphys_after2015} -eq 0 ]; then

  if [ "${CCPP_PHYS_SUITE}" = "GFS" ]; then
    FIXam_FILES_SYSDIR[${indx_ozphys_2015}]="${ozphys_after2015_fn}"
  fi

elif [ ${num_files_ozphys_2015} -eq 0 ] && \
     [ ${num_files_ozphys_after2015} -eq 1 ]; then

  if [ "${CCPP_PHYS_SUITE}" = "GSD" ]; then
    FIXam_FILES_SYSDIR[${indx_ozphys_after2015}]="${ozphys_2015_fn}"
  fi

else

  FIXam_FILES_SYSDIR_str=$( printf "\"%s\"\n" "${FIXam_FILES_SYSDIR[@]}" )
  print_err_msg_exit "\
The array FIXam_FILES_SYSDIR containing the names of the fixed files in
the system directory (FIXgsm) to copy or link to has been specified in-
correctly because it contains no or more than one occurrence of the 
ozone production/loss file(s) (whose names are specified in the varia-
bles ozphys_2015_fn and ozphys_after2015_fn):
  FIXgsm = \"${FIXgsm}\"
  ozphys_2015_fn = \"${ozphys_2015_fn}\"
  num_files_ozphys_2015_fn = \"${num_files_ozphys_2015_fn}\"
  ozphys_after2015_fn = \"${ozphys_after2015_fn}\"
  num_files_ozphys_after2015_fn = \"${num_files_ozphys_after2015_fn}\"
  FIXam_FILES_SYSDIR = 
(
${FIXam_FILES_SYSDIR_str}
)
Please check the contents of the FIXam_FILES_SYSDIR array and rerun."

fi
#
#-----------------------------------------------------------------------
#
# Copy the workflow (re)launch script to the experiment directory.
#
#-----------------------------------------------------------------------
#
print_info_msg "
Creating symlink in the experiment directory (EXPTDIR) to the workflow
launch script (WFLOW_LAUNCH_SCRIPT_FP):
  EXPTDIR = \"${EXPTDIR}\"
  WFLOW_LAUNCH_SCRIPT_FP = \"${WFLOW_LAUNCH_SCRIPT_FP}\""
ln_vrfy -fs "${WFLOW_LAUNCH_SCRIPT_FP}" "$EXPTDIR"
#
#-----------------------------------------------------------------------
#
# If USE_CRON_TO_RELAUNCH is set to TRUE, add a line to the user's cron
# table to call the (re)launch script every CRON_RELAUNCH_INTVL_MNTS mi-
# nutes.
#
#-----------------------------------------------------------------------
#
if [ "${USE_CRON_TO_RELAUNCH}" = "TRUE" ]; then
#
# Make a backup copy of the user's crontab file and save it in a file.
#
  time_stamp=$( date "+%Y%m%d%H%M%S" )
  crontab_backup_fp="$EXPTDIR/crontab.bak.${time_stamp}"
  print_info_msg "
Copying contents of user cron table to backup file:
  crontab_backup_fp = \"${crontab_backup_fp}\""
  crontab -l > ${crontab_backup_fp}
#
# Below, we use "grep" to determine whether the crontab line that the 
# variable CRONTAB_LINE contains is already present in the cron table.  
# For that purpose, we need to escape the asterisks in the string in 
# CRONTAB_LINE with backslashes.  Do this next.
#
  crontab_line_esc_astr=$( printf "%s" "${CRONTAB_LINE}" | \
                           sed -r -e "s%[*]%\\\\*%g" )
#
# In the grep command below, the "^" at the beginning of the string be-
# ing passed to grep is a start-of-line anchor while the "$" at the end
# of the string is an end-of-line anchor.  Thus, in order for grep to 
# find a match on any given line of the output of "crontab -l", that 
# line must contain exactly the string in the variable crontab_line_-
# esc_astr without any leading or trailing characters.  This is to eli-
# minate situations in which a line in the output of "crontab -l" con-
# tains the string in crontab_line_esc_astr but is precedeeded, for ex-
# ample, by the comment character "#" (in which case cron ignores that
# line) and/or is followed by further commands that are not part of the 
# string in crontab_line_esc_astr (in which case it does something more
# than the command portion of the string in crontab_line_esc_astr does).
#
  grep_output=$( crontab -l | grep "^${crontab_line_esc_astr}$" )
  exit_status=$?

  if [ "${exit_status}" -eq 0 ]; then

    print_info_msg "
The following line already exists in the cron table and thus will not be
added:
  CRONTAB_LINE = \"${CRONTAB_LINE}\""
  
  else

    print_info_msg "
Adding the following line to the cron table in order to automatically
resubmit FV3SAR workflow:
  CRONTAB_LINE = \"${CRONTAB_LINE}\""

    ( crontab -l; echo "${CRONTAB_LINE}" ) | crontab -

  fi

fi
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
if [ "${RUN_ENVIR}" = "nco" ]; then

  glob_pattern="C*_mosaic.nc"
  cd_vrfy $FIXsar
  num_files=$( ls -1 ${glob_pattern} 2>/dev/null | wc -l )

  if [ "${num_files}" -ne "1" ]; then
    print_err_msg_exit "\
Exactly one file must exist in directory FIXsar matching the globbing
pattern glob_pattern:
  FIXsar = \"${FIXsar}\"
  glob_pattern = \"${glob_pattern}\"
  num_files = \"${num_files}\""
  fi

  fn=$( ls -1 ${glob_pattern} )
  RES=$( printf "%s" $fn | sed -n -r -e "s/^C([0-9]*)_mosaic.nc/\1/p" )
  CRES="C$RES"
echo "RES = $RES"

#  RES_equiv=$( ncdump -h "${grid_fn}" | grep -o ":RES_equiv = [0-9]\+" | grep -o "[0-9]")
#  RES_equiv=${RES_equiv//$'\n'/}
#printf "%s\n" "RES_equiv = $RES_equiv"
#  CRES_equiv="C${RES_equiv}"
#printf "%s\n" "CRES_equiv = $CRES_equiv"
#
#  RES="$RES_equiv"
#  CRES="$CRES_equiv"

  set_file_param "${GLOBAL_VAR_DEFNS_FP}" "RES" "${RES}"
  set_file_param "${GLOBAL_VAR_DEFNS_FP}" "CRES" "${CRES}"

else
#
#-----------------------------------------------------------------------
#
# If the grid file generation task in the workflow is going to be 
# skipped (because pregenerated files are available), create links in 
# the FIXsar directory to the pregenerated grid files.
#
#-----------------------------------------------------------------------
#
  if [ "${RUN_TASK_MAKE_GRID}" = "FALSE" ]; then
    $USHDIR/link_fix.sh \
      verbose="FALSE" \
      global_var_defns_fp="${GLOBAL_VAR_DEFNS_FP}" \
      file_group="grid" || \
    print_err_msg_exit "\
Call to script to create links to grid files failed."
  fi
#
#-----------------------------------------------------------------------
#
# If the orography file generation task in the workflow is going to be 
# skipped (because pregenerated files are available), create links in 
# the FIXsar directory to the pregenerated orography files.
#
#-----------------------------------------------------------------------
#
  if [ "${RUN_TASK_MAKE_OROG}" = "FALSE" ]; then
    $USHDIR/link_fix.sh \
      verbose="FALSE" \
      global_var_defns_fp="${GLOBAL_VAR_DEFNS_FP}" \
      file_group="orog" || \
    print_err_msg_exit "\
Call to script to create links to orography files failed."
  fi
#
#-----------------------------------------------------------------------
#
# If the surface climatology file generation task in the workflow is 
# going to be skipped (because pregenerated files are available), create
# links in the FIXsar directory to the pregenerated surface climatology
# files.
#
#-----------------------------------------------------------------------
#
  if [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "FALSE" ]; then
    $USHDIR/link_fix.sh \
      verbose="FALSE" \
      global_var_defns_fp="${GLOBAL_VAR_DEFNS_FP}" \
      file_group="sfc_climo" || \
    print_err_msg_exit "\
Call to script to create links to surface climatology files failed."
  fi

fi
#
#-----------------------------------------------------------------------
#
# Copy fixed files from system directory to the FIXam directory (which 
# is under the experiment directory).  Note that some of these files get
# renamed.
#
#-----------------------------------------------------------------------
#

# For nco, we assume the following copy operation is done beforehand, but
# that can be changed.
if [ "${RUN_ENVIR}" != "nco" ]; then

  print_info_msg "$VERBOSE" "
Copying fixed files from system directory to the experiment directory..."

  check_for_preexist_dir $FIXam "delete"
  mkdir -p $FIXam

  cp_vrfy $FIXgsm/global_hyblev.l65.txt $FIXam
  for (( i=0; i<${NUM_FIXam_FILES}; i++ )); do
    cp_vrfy $FIXgsm/${FIXam_FILES_SYSDIR[$i]} \
            $FIXam/${FIXam_FILES_EXPTDIR[$i]}
  done

fi
#
#-----------------------------------------------------------------------
#
# Copy templates of various input files to the experiment directory.
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Copying templates of various input files to the experiment directory..."
#
#-----------------------------------------------------------------------
#
# If using CCPP...
#
#-----------------------------------------------------------------------
#
if [ "${USE_CCPP}" = "TRUE" ]; then
#
#-----------------------------------------------------------------------
#
# If using CCPP with the GFS physics suite...
#
#-----------------------------------------------------------------------
#
  if [ "${CCPP_PHYS_SUITE}" = "GFS" ]; then

    if [ "${EXTRN_MDL_NAME_ICS}" = "GSMGFS" -o \
         "${EXTRN_MDL_NAME_ICS}" = "FV3GFS" ] && \
       [ "${EXTRN_MDL_NAME_LBCS}" = "GSMGFS" -o \
         "${EXTRN_MDL_NAME_LBCS}" = "FV3GFS" ]; then

      print_info_msg "$VERBOSE" "
Copying the FV3 namelist file for the GFS physics suite to the experi-
ment directory..."
      cp_vrfy ${TEMPLATE_DIR}/${FV3_NML_CCPP_GFSPHYS_GFSEXTRN_FN} \
              $EXPTDIR/${FV3_NML_FN}

    else

      print_err_msg_exit "\
A template FV3 namelist file is not available for the following combina-
tion of physics suite and external models for ICs and LBCs:
  CCPP_PHYS_SUITE = \"${CCPP_PHYS_SUITE}\"
  EXTRN_MDL_NAME_ICS = \"${EXTRN_MDL_NAME_ICS}\"
  EXTRN_MDL_NAME_LBCS = \"${EXTRN_MDL_NAME_LBCS}\"
Please change one or more of these parameters or provide a template
namelist file for this combination (and change workflow generation 
script(s) accordingly) and rerun."

    fi

    print_info_msg "$VERBOSE" "
Copying the field table file for the GFS physics suite to the experiment
directory..."
    cp_vrfy ${TEMPLATE_DIR}/${FIELD_TABLE_FN} \
            $EXPTDIR

    print_info_msg "$VERBOSE" "
Copying the CCPP XML file for the GFS physics suite to the experiment 
directory..."
    cp_vrfy ${NEMSfv3gfs_DIR}/FV3/ccpp/suites/suite_FV3_GFS_2017_gfdlmp.xml \
            $EXPTDIR/suite_FV3_GFS_2017_gfdlmp.xml
#
#-----------------------------------------------------------------------
#
# If using CCPP with the GSD physics suite...
#
#-----------------------------------------------------------------------
#
  elif [ "${CCPP_PHYS_SUITE}" = "GSD" ]; then

    print_info_msg "$VERBOSE" "
Copying the FV3 namelist file for the GSD physics suite to the experi-
ment directory..."
    cp_vrfy ${TEMPLATE_DIR}/${FV3_NML_CCPP_GSDPHYS_FN} \
            $EXPTDIR/${FV3_NML_FN}

    print_info_msg "$VERBOSE" "
Copying the field table file for the GSD physics suite to the experiment
directory..."
    cp_vrfy ${TEMPLATE_DIR}/${FIELD_TABLE_CCPP_GSD_FN} \
            $EXPTDIR/${FIELD_TABLE_FN}

    print_info_msg "$VERBOSE" "
Copying the CCPP XML file for the GSD physics suite to the experiment 
directory..."
    cp_vrfy ${NEMSfv3gfs_DIR}/FV3/ccpp/suites/suite_FV3_GSD_v0.xml \
            $EXPTDIR/suite_FV3_GSD_v0.xml

    print_info_msg "$VERBOSE" "
Copying the CCN fixed file needed by Thompson microphysics (part of the
GSD suite) to the experiment directory..."
    cp_vrfy $FIXgsd/CCN_ACTIVATE.BIN $EXPTDIR

  fi
#
#-----------------------------------------------------------------------
#
# If not using CCPP...
#
#-----------------------------------------------------------------------
#
else

  cp_vrfy ${TEMPLATE_DIR}/${FV3_NML_FN} $EXPTDIR
  cp_vrfy ${TEMPLATE_DIR}/${FIELD_TABLE_FN} $EXPTDIR

fi

cp_vrfy ${TEMPLATE_DIR}/${DATA_TABLE_FN} $EXPTDIR
cp_vrfy ${TEMPLATE_DIR}/${NEMS_CONFIG_FN} $EXPTDIR
#
#-----------------------------------------------------------------------
#
# Set the full path to the FV3SAR namelist file.  Then set parameters in
# that file.
#
#-----------------------------------------------------------------------
#
FV3_NML_FP="$EXPTDIR/${FV3_NML_FN}"

print_info_msg "$VERBOSE" "
Setting parameters in FV3 namelist file (FV3_NML_FP):
  FV3_NML_FP = \"${FV3_NML_FP}\""
#
# Set npx_T7 and npy_T7, which are just NX_T7 plus 1 and NY_T7 plus 1,
# respectively.  These need to be set in the FV3SAR Fortran namelist
# file.  They represent the number of cell vertices in the x and y di-
# rections on the regional grid (tile 7).
#
npx_T7=$(( NX_T7+1 ))
npy_T7=$(( NY_T7+1 ))
#
# Set parameters.
#
set_file_param "${FV3_NML_FP}" "blocksize" "$BLOCKSIZE"
set_file_param "${FV3_NML_FP}" "layout" "${LAYOUT_X},${LAYOUT_Y}"
set_file_param "${FV3_NML_FP}" "npx" "${npx_T7}"
set_file_param "${FV3_NML_FP}" "npy" "${npy_T7}"

if [ "${GRID_GEN_METHOD}" = "GFDLgrid" ]; then
# Question:
# For a regional grid (i.e. one that only has a tile 7) should the co-
# ordinates that target_lon and target_lat get set to be those of the 
# center of tile 6 (of the parent grid) or those of tile 7?  These two
# are not necessarily the same [although assuming there is only one re-
# gional domain within tile 6, i.e. assuming there is no tile 8, 9, etc,
# there is no reason not to center tile 7 with respect to tile 6].
  set_file_param "${FV3_NML_FP}" "target_lon" "${LON_CTR_T6}"
  set_file_param "${FV3_NML_FP}" "target_lat" "${LAT_CTR_T6}"
elif [ "${GRID_GEN_METHOD}" = "JPgrid" ]; then
  set_file_param "${FV3_NML_FP}" "target_lon" "${LON_RGNL_CTR}"
  set_file_param "${FV3_NML_FP}" "target_lat" "${LAT_RGNL_CTR}"
fi
set_file_param "${FV3_NML_FP}" "stretch_fac" "${STRETCH_FAC}"
set_file_param "${FV3_NML_FP}" "bc_update_interval" "${LBC_UPDATE_INTVL_HRS}"
#
# For GSD physics, set the parameter lsoil according to the external mo-
# dels specified for ICs and LBCs.
#
if [ "${CCPP_PHYS_SUITE}" = "GSD" ]; then

  if [ "${EXTRN_MDL_NAME_ICS}" = "GSMGFS" -o \
       "${EXTRN_MDL_NAME_ICS}" = "FV3GFS" ] && \
     [ "${EXTRN_MDL_NAME_LBCS}" = "GSMGFS" -o \
       "${EXTRN_MDL_NAME_LBCS}" = "FV3GFS" ]; then
    set_file_param "${FV3_NML_FP}" "lsoil" "4"
  elif [ "${EXTRN_MDL_NAME_ICS}" = "RAPX" -o \
         "${EXTRN_MDL_NAME_ICS}" = "HRRRX" ] && \
       [ "${EXTRN_MDL_NAME_LBCS}" = "RAPX" -o \
         "${EXTRN_MDL_NAME_LBCS}" = "HRRRX" ]; then
    set_file_param "${FV3_NML_FP}" "lsoil" "9"
  else
    print_err_msg_exit "\
The value to set the variable lsoil to in the FV3 namelist file (FV3_-
NML_FP) has not been specified for the following combination of physics
suite and external models for ICs and LBCs:
  CCPP_PHYS_SUITE = \"${CCPP_PHYS_SUITE}\"
  EXTRN_MDL_NAME_ICS = \"${EXTRN_MDL_NAME_ICS}\"
  EXTRN_MDL_NAME_LBCS = \"${EXTRN_MDL_NAME_LBCS}\"
Please change one or more of these parameters or provide a value for 
lsoil (and change workflow generation script(s) accordingly) and rerun."
  fi

fi
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

}
#
#-----------------------------------------------------------------------
#
# Call the function defined above.
#
#-----------------------------------------------------------------------
#
generate_FV3SAR_wflow


