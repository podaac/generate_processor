FUNCTION  modis_notify_operator, routine_name, msg_type, msg, email, sigevent, temp_dir,msg2report, i_data
   ;msg2report
   ;   0=suppress all messages
   ;   1=error
   ;   2=warning
   ;   4=information, 
   ;   3=error+warning
   ;   5=error+information,
   ;   6=warning+information
   ;   7=report all messages

   ;help,        routine_name
   ;help,        msg_type
   ;help,        msg
   ;help,        email
   ;help,        sigevent
   ;help,        temp_dir
   ;help,        msg2report
   ;return;

   ; Determine if message should be reported
   report_it = 0
   msg_type  = STRTRIM(STRLOWCASE(msg_type),2)

   CASE 1 OF
      msg2report EQ 7                                                         : report_it = 1
      msg2report EQ 6 AND (msg_type EQ 'warning' OR msg_type EQ 'information'): report_it = 1
      msg2report EQ 5 AND (msg_type EQ 'error' OR msg_type EQ 'information')  : report_it = 1
      msg2report EQ 4 AND msg_type EQ 'information'                           : report_it = 1
      msg2report EQ 3 AND (msg_type EQ 'error' OR msg_type EQ 'warning')      : report_it = 1
      msg2report EQ 2 AND msg_type EQ 'warning'                               : report_it = 1
      msg2report EQ 1 AND msg_type EQ 'error'                                 : report_it = 1
      ELSE: report_it = 0
   ENDCASE

   ; Determine message type
   IF STRTRIM(sigevent,2) NE '' AND report_it THEN BEGIN

      CASE msg_type OF
         'information': msg_type = 'INFO'
         'warning'    : msg_type = 'WARN'
         'error'      : msg_type = 'ERROR'
         ELSE: PRINT, 'Invalid msg_type: ', msg_type
      ENDCASE

   ENDIF

   ; Call notify.py to log and send notifications
   python_lib = GETENV('GHRSST_PYTHON_LIB_DIRECTORY')
   system_command_string = python_lib + '/notify.py ' $ 
                           + '-t ' + '"' + STRTRIM(STRING(msg_type),2) + '"' $
                           + ' -d ' + '"' + STRTRIM(STRING(routine_name),2) + ': ' + STRTRIM(STRING(msg),2) + '"' $
                           + ' -i ' + '"' + STRTRIM(STRING(i_data),2) + '"'
   ; PRINT, "system command string: ", system_command_string
   SPAWN, system_command_string, result, error, EXIT_STATUS=exit_status

   ; Print out captured standard out
   FOREACH element, result DO PRINT, element

   ; Exit if encountered error
   IF (exit_status NE 0 ) THEN BEGIN
      PRINT, "ERROR encountered when calling system command: ", system_command_string
      PRINT, "Exiting program."
      EXIT, status = 1
   ENDIF

END
; ghrsst_notify_operator



FUNCTION wrapper_ghrsst_notify_operator, i_routine_name, i_msg_type, i_msg, i_data

email = "DUMMY_EMAIL"
sigevent = GETENV('GHRSST_SIGEVENT_URL');
sigevent_clause = "SIGEVENT=" + sigevent + "&category=GENERATE&provider=jpl";
temp_dir = "/tmp/";
msg2report = 7;

donotcare = modis_notify_operator($
                i_routine_name,$
                i_msg_type,$
                i_msg,$
                email,$
                sigevent_clause,$
                temp_dir,$
                msg2report,$
                i_data);

END

