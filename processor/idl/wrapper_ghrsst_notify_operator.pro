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


   oUrl = OBJ_NEW('IDLnetUrl')

   ; If the url object throws an error it will be caught here
   CATCH, errorStatus
   IF (errorStatus NE 0) THEN BEGIN
      CATCH, /CANCEL

      ; Display the error msg in a dialog and in the IDL output log
      PRINT, '****** ERROR: ghrsst_notify_operator ******'
      PRINT, !ERROR_STATE.msg

      ; Get the properties that will tell us more about the error.
      oUrl->GetProperty, RESPONSE_CODE=rspCode, $
         RESPONSE_HEADER=rspHdr, RESPONSE_FILENAME=rspFn

      IF rspCode NE 0 THEN BEGIN
         PRINT, 'URL response code     = ', rspCode
         PRINT, 'URL response header   = ', rspHdr
         PRINT, 'URL response filename = ', rspFn
      ENDIF

      ; Destroy the url object
      OBJ_DESTROY, oUrl
      RETURN, 1
   ENDIF

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

;   IF STRTRIM(email,2) NE '' AND report_it THEN BEGIN
;      uniq_suffix   = STRTRIM(ULONG64(ABS(RANDOMN(seed))*1000000.0),2)
;      tmpfile       = temp_dir+'msg'+uniq_suffix
;      SPAWN,'echo "***** '+msg_type+' ('+routine_name+') *****" >> '+tmpfile
;      FOR i = 0, N_ELEMENTS(msg)-1 DO SPAWN,'echo "'+msg[i]+'" >> '+tmpfile
;      SPAWN,'where mail',mail_cmd
;      mail_cmd      = mail_cmd[N_ELEMENTS(mail_cmd)-1]
;      SPAWN,'where rm',rm_cmd
;      rm_cmd        = rm_cmd[N_ELEMENTS(rm_cmd)-1]
;      SPAWN,mail_cmd+' -s "State of the Oceans '+msg_type+'" '+email+' < '+tmpfile
;      SPAWN,rm_cmd+' '+tmpfile
;   ENDIF

;print,'sigevent = ',sigevent

   IF STRTRIM(sigevent,2) NE '' AND report_it THEN BEGIN
      ;========================================================================
      ; encoded string for reporting to SigEvent:
      ;
      ; SIGEVENT=url&CATEGORY=category&PROVIDER=provider
      ;
      ; NOTE: SigEvent message can not exceed 256 characters!!!!!
      ;========================================================================
      url      = ''
      category = ''
      provider = ''

;help,     sigevent 

      sep1             = STR_SEP(sigevent,'&')
      sep2             = STR_SEP(sep1[0],'=')
      IF N_ELEMENTS(sep2) EQ 2 THEN BEGIN
         url = STRTRIM(sep2[1],2)
         FOR i = 1, N_ELEMENTS(sep1)-1 DO BEGIN
            sep2             = STR_SEP(sep1[i],'=')
            IF N_ELEMENTS(sep2) EQ 2 THEN BEGIN
               CASE STRUPCASE(STRTRIM(sep2[0],2)) OF
                  'CATEGORY': category = STRTRIM(sep2[1],2)
                  'PROVIDER': provider = STRTRIM(sep2[1],2)
                  ELSE:
               ENDCASE
            ENDIF
         ENDFOR
      ENDIF

      CASE msg_type OF
         'information': msg_type = 'INFO'
         'warning'    : msg_type = 'WARN'
         'error'      : msg_type = 'ERROR'
         ELSE:
      ENDCASE
      ;SPAWN,'where hostname',hostname_cmd
      ;SPAWN,hostname_cmd,hostname
      SPAWN,'echo $HOST',hostname
      hostname = STRTRIM(hostname[0],2)

      MAX_SIGEVENT_DESC_LENGTH = 256
      desc     = routine_name+':'
      done     = 0
      msg_cnt  = 0L
      WHILE NOT done AND msg_cnt LT N_ELEMENTS(msg) DO BEGIN
         desc    = desc+msg[msg_cnt]+' '
         msg_cnt = msg_cnt + 1L
         desc    = STRCOMPRESS(desc)
         IF STRLEN(desc) GE MAX_SIGEVENT_DESC_LENGTH THEN BEGIN
            done = 1
            desc = STRMID(desc,0,253)+'...'
         ENDIF
      ENDWHILE

;;;ckt,feb2011      desc     = ''
;;;ckt,feb2011      FOR i = 0, N_ELEMENTS(msg)-1 DO desc = desc+msg[i]+' '
;;;ckt,feb2011      desc     = STRCOMPRESS(desc)

      sigevt_url         = url
      sigevt_format      = 'TEXT'
      sigevt_category    = category
      sigevt_type        = msg_type
      sigevt_source      = 'GHRSST-PROCESSING'
      sigevt_provider    = provider
      sigevt_computer    = hostname
;;;ckt,feb2011      sigevt_description = '***** '+routine_name+': '+desc
      sigevt_description = desc

       ; If the i_data starts with '/', we know it is a file name.

       data_as_text = i_data;

;       if (STRPOS(i_data,'/') EQ 0) then begin
;           ;
;           ; Open file for reading only.  Must remember to free the logical unit after done.
;           ;
;
;           openr, file_unit, i_data, ERROR = err,/GET_LUN;
;
;           ; If err is nonzero, something bad happened.  Print the error message
;           ; to the standard error file (logical unit -2):
;
;           ; Changed later to print to log if desired.
;           
;           if (err NE 0) then begin
;               print, 'read_dataset: ERROR, Cannot open file for input.' + i_data ;
;               return;
;           end
;
;           line_content = '';  We have to declare what we are reading as text.
;           line_index = 0;
;           
;           data_as_text = "";
;
;           WHILE NOT eof(file_unit) DO BEGIN
;               readf,file_unit,line_content;
;               data_as_text += line_content + "\n"; Add a carriage return to our string.
;               line_index = line_index + 1
;           ENDWHILE
;           line_index = line_index - 1;
;           free_lun,file_unit
;       endif 

;print, "STRLEN(data_as_text) = ",STRLEN(data_as_text);

; Comment out old way of calling.

;      rest_service_call  = sigevt_url    +'/sigevent/events/create?'+ $
;                           'format='     +sigevt_format         +'&'+ $
;                           'type='       +sigevt_type           +'&'+ $
;                           'category='   +sigevt_category       +'&'+ $
;                           'source='     +sigevt_source         +'&'+ $
;                           'provider='   +sigevt_provider       +'&'+ $
;                           'computer='   +sigevt_computer       +'&'+ $
;                           'description='+sigevt_description

      if ((STRPOS(i_data,'/') EQ 0) AND (FILE_TEST(i_data))) then begin
          ; If the data content is a file name, we send the sigevent using curl and the data as a re-direction.
          ;
          ; Example call using curl:
          ;
          ; curl -F data="</home/qchau/workspace/generate/ghrsst/combine/src/main/perl/hello.there" -F format=TEXT -F type=ERROR -F category=UNCATEGORIZED -F source=GHRSST-PROCESSING -F provider=jpl -F computer=lapinta -F description="modis_level2_combiner.pl:My script modis_level2_combiner.pl found SST files too old for processing. " http://lanina.jpl.nasa.gov:8100/sigevent/events/create

          curl_service_call  = '-F data="<'     +i_data + '"'          +' '+ $
                               '-F format='     +sigevt_format         +' '+ $
                               '-F type='       +sigevt_type           +' '+ $
                               '-F category='   +sigevt_category       +' '+ $
                               '-F source='     +sigevt_source         +' '+ $
                               '-F provider='   +sigevt_provider       +' '+ $
                               '-F computer='   +sigevt_computer       +' '+ $
                               '-F description="'+sigevt_description + '"' + ' ' + $
                               sigevt_url    +'/sigevent/events/create';

;print ,'curl ' + curl_service_call; 

          SPAWN,'curl  ' + curl_service_call + " >& /dev/null "; 

      endif else begin 
          ; If the data content is small, we can send it as part of the data= parameter.

          if (STRLEN(STRTRIM(data_as_text,2)) GT 0) then begin
              ; The data portion has something in it, we will include it.
              rest_service_call  = sigevt_url    +'/sigevent/events/create?'+ $
                                   'format='     +sigevt_format         +'&'+ $
                                   'type='       +sigevt_type           +'&'+ $
                                   'category='   +sigevt_category       +'&'+ $
                                   'source='     +sigevt_source         +'&'+ $
                                   'provider='   +sigevt_provider       +'&'+ $
                                   'computer='   +sigevt_computer       +'&'+ $
                                   'data="'      +data_as_text + '"'    +'&'+ $
                                   'description='+sigevt_description
          endif else begin
              ; The data is empty, no need to include it.
              rest_service_call  = sigevt_url    +'/sigevent/events/create?'+ $
                                   'format='     +sigevt_format         +'&'+ $
                                   'type='       +sigevt_type           +'&'+ $
                                   'category='   +sigevt_category       +'&'+ $
                                   'source='     +sigevt_source         +'&'+ $
                                   'provider='   +sigevt_provider       +'&'+ $
                                   'computer='   +sigevt_computer       +'&'+ $
                                   'description='+sigevt_description

          endelse

          resp               = oUrl->Get(URL=rest_service_call,/STRING_ARRAY)
          msg2               = ['   SigEvent URL','        '+rest_service_call,'   SigEvent Return Value','        '+resp]

;print, 'rest_service_call [', rest_service_call, "]";

;help,      sigevt_url
;help,      sigevt_format
;help,      sigevt_category
;help,      sigevt_type
;help,      sigevt_source
;help,      sigevt_provider
;help,      sigevt_computer
;help,      sigevt_description
;help,      rest_service_call

      endelse

;      FOR i = 0, N_ELEMENTS(msg2)-1 DO PRINT,msg2[i]
   ENDIF
;   PRINT,''
;   PRINT, '***** '+msg_type+' ('+routine_name+') *****'
;   FOR i = 0, N_ELEMENTS(msg)-1 DO PRINT,msg[i]

   OBJ_DESTROY,oUrl

END
; ghrsst_notify_operator



FUNCTION wrapper_ghrsst_notify_operator, i_routine_name, i_msg_type, i_msg, i_data

email = "DUMMY_EMAIL"
sigevent = GETENV('GHRSST_SIGEVENT_URL');
sigevent_clause = "SIGEVENT=" + sigevent + "&category=UNCATEGORIZED&provider=jpl";
temp_dir = "/tmp/";
msg2report = 7;
;i_data = "";

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

