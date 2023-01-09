;  Copyright 2006, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.

; $Id: make_modisl2p_meta.pro,v 1.9 2007/06/20 18:16:46 qchau Exp $
; make_modisl2p_meta.pro  e. armstrong    Caltech/JPL/NASA

FUNCTION make_modisl2p_meta,$
         l2p_file,$
         meta_file

;---------------------------------------------------------------
; SYNOPSIS:
; Create the GHRSST FR granule metadata record for a MODIS L2P file.
; Many of the metadata attributes are read from the netCDF global
; attributes

; CALLS:
; get_global_attributes(), iso_date() 

; USAGE:
; IDL> make_modisl2p_meta, 'L2P_file.nc'
;---------------------------------------------------------------

;if n_params() ne 2 then begin
;    usage
;    stop
;endif

; Load constants.  No ending semicolon is required.

@modis_data_config.cfg

o_status = SUCCESS;
;-----------------------------------------------
; open the netCDF L2P and read global attributes
;-----------------------------------------------
nid = ncdf_open( l2p_file, /nowrite )

; inquire about this file; returns structure
file_info = ncdf_inquire( nid )

; retrieve the global attributes
;print, '. . . reading global attributes '
global_atts = get_global_attributes( nid, file_info )

ncdf_close, nid


;--------------------------------
; Get just the file name without the directory.
;--------------------------------

splitted_string = strsplit(l2p_file, "/", /REGEX, /EXTRACT);

num_substrings = SIZE(splitted_string,/N_ELEMENTS);
file_name_only = splitted_string[num_substrings-1];

;print, 'l2p_file = ', l2p_file;
;print, 'file_name_only = ', file_name_only;

;--------------------------------
; Get the directory name.  Subtract 2 since we don't want the file name.
;--------------------------------

directory_name = ""; 
for i = 0, num_substrings-2 do begin
    directory_name = directory_name + "/" + splitted_string[i];
endfor

;print, 'directory_name = ', directory_name; 

;--------------------------------
; create the FR metadata filename
;--------------------------------
;meta_file = strsplit(file_name_only, '.nc', /regex, /extract )
;meta_file = directory_name + "/" + "FR-" + meta_file + '.xml'

;print, 'meta_file = ', meta_file; 

;--------------------------------
; Append the file name to a temporary file so another program can get access to it.
; This name is hard-coded.
;--------------------------------
; open FR record 
;name_drop_filename = './meta_filename_drop.dat';
;openw, name_drop_id, name_drop_filename, /APPEND, /GET_LUN
;printf, name_drop_id, meta_file; 
;close, name_drop_id;

;return;

;--------------------------------
; create the FR metadata filename
;--------------------------------
;meta_file = strsplit( l2p_file, '.nc', /regex, /extract )
;meta_file = "FR-" + meta_file + '.xml'

; open FR record 
openw, fr_id, meta_file, /get_lun


;--------------------------------
; write FR metadata contents
;--------------------------------
;print, '. . . writing FR metadata attributes'
printf, fr_id, '<?xml version="1.0" encoding="UTF-8"?> '
printf, fr_id,  '<!DOCTYPE MMR_FR SYSTEM "mmr_fr.dtd"> '
printf, fr_id, '<MMR_FR> '

printf, fr_id, '<Entry_ID>' + global_atts.DSD_entry_id + '</Entry_ID> '
printf, fr_id, '<File_Name>' + file_name_only + '</File_Name> '
	file_release_date = iso_date( global_atts.creation_date )	
printf, fr_id, '<File_Release_Date>' + file_release_date + '</File_Release_Date> '
printf, fr_id, '<File_Version>' + global_atts.product_version + '</File_Version> '
printf, fr_id, '<Temporal_Coverage> '

        ; get the ISO 8601 start and end dates
	start_date = strsplit( global_atts.start_date,  /extract ) ; split white
	start_date = strsplit( start_date[0], '-', /extract )      ; split '-'
	start_time = strsplit( global_atts.start_time,  /extract )
	start_time = strsplit( start_time[0], ':', /extract )
	iso_start_date = start_date[0] + start_date[1] + start_date[2] + 'T' + $
			 start_time[0] + start_time[1] + start_time[2] + 'Z'

	stop_date = strsplit( global_atts.stop_date,  /extract )
	stop_date = strsplit( stop_date[0], '-', /extract )
	stop_time = strsplit( global_atts.stop_time,  /extract )
	stop_time = strsplit( stop_time[0], ':', /extract )
	iso_stop_date = stop_date[0] + stop_date[1] + stop_date[2] + 'T' + $
		        stop_time[0] + stop_time[1] + stop_time[2] + 'Z'

        ;
        ; Make sure we only have 3 significant digits after the decimal points of geo-location
        ; attributes.  Add however many zeros after the decimal portion to come up with 3
        ; digits.
        ;
        max_digits_after_decimal_points = 3;
        digits_to_copy = 0;
        zero_array = STRING('000');
        number_of_zeros = "";

        str_southernmost_latitude = STRING(global_atts.southernmost_latitude);
        str_southernmost_latitude = STRSPLIT(str_southernmost_latitude, '.', /EXTRACT);
        if (STRLEN(str_southernmost_latitude[1]) GT max_digits_after_decimal_points) then begin
            digits_to_copy = max_digits_after_decimal_points;
            number_of_zeros = "";
        endif else begin
            digits_to_copy = STRLEN(str_southernmost_latitude[1]); 
            number_of_zeros =  STRMID(zero_array,0,$
                                   max_digits_after_decimal_points-digits_to_copy);
        endelse
        str_southernmost_latitude = STRTRIM(str_southernmost_latitude[0],2) + "." + $
            STRMID(str_southernmost_latitude[1],0,digits_to_copy) + number_of_zeros;


        str_northernmost_latitude = STRING(global_atts.northernmost_latitude);
        str_northernmost_latitude = STRSPLIT(str_northernmost_latitude, '.', /EXTRACT);
        if (STRLEN(str_northernmost_latitude[1]) GT max_digits_after_decimal_points) then begin
            digits_to_copy = max_digits_after_decimal_points;
            number_of_zeros = "";
        endif else begin
            digits_to_copy = STRLEN(str_northernmost_latitude[1]); 
            number_of_zeros =  STRMID(zero_array,0,$
                                   max_digits_after_decimal_points-digits_to_copy);
        endelse
        str_northernmost_latitude = STRTRIM(str_northernmost_latitude[0],2) + "." + $
            STRMID(str_northernmost_latitude[1],0,digits_to_copy) + number_of_zeros;


        str_westernmost_longitude = STRING(global_atts.westernmost_longitude);
        str_westernmost_longitude = STRSPLIT(str_westernmost_longitude, '.', /EXTRACT);
        if (STRLEN(str_westernmost_longitude[1]) GT max_digits_after_decimal_points) then begin
            digits_to_copy = max_digits_after_decimal_points;
            number_of_zeros = "";
        endif else begin
            digits_to_copy = STRLEN(str_westernmost_longitude[1]); 
            number_of_zeros =  STRMID(zero_array,0,$
                                   max_digits_after_decimal_points-digits_to_copy);
        endelse
        str_westernmost_longitude = STRTRIM(str_westernmost_longitude[0],2) + "." + $
            STRMID(str_westernmost_longitude[1],0,digits_to_copy) + number_of_zeros;


        str_easternmost_longitude = STRING(global_atts.easternmost_longitude);
        str_easternmost_longitude = STRSPLIT(str_easternmost_longitude, '.', /EXTRACT);
        if (STRLEN(str_easternmost_longitude[1]) GT max_digits_after_decimal_points) then begin
            digits_to_copy = max_digits_after_decimal_points;
            number_of_zeros = "";
        endif else begin
            digits_to_copy = STRLEN(str_easternmost_longitude[1]); 
            number_of_zeros =  STRMID(zero_array,0,$
                                   max_digits_after_decimal_points-digits_to_copy);
        endelse
        str_easternmost_longitude = STRTRIM(str_easternmost_longitude[0],2) + "." + $
            STRMID(str_easternmost_longitude[1],0,digits_to_copy) + number_of_zeros;

printf, fr_id, '<Start_Date>' + iso_start_date + '</Start_Date> '
printf, fr_id, '<Stop_Date>'  + iso_stop_date + '</Stop_Date> '
printf, fr_id, '</Temporal_Coverage> '
printf, fr_id, '<Spatial_Coverage> '
printf, fr_id, '<Southernmost_Latitude>'+ str_southernmost_latitude + '</Southernmost_Latitude> '
printf, fr_id, '<Northernmost_Latitude>'+ str_northernmost_latitude + '</Northernmost_Latitude> '
printf, fr_id, '<Westernmost_Longitude>'+ str_westernmost_longitude + '</Westernmost_Longitude> '
printf, fr_id, '<Easternmost_Longitude>'+ str_easternmost_longitude + '</Easternmost_Longitude> '
printf, fr_id, '</Spatial_Coverage> '
printf, fr_id, '<Personnel> '
	role 		= 'Technical Contact'
	first_name 	= 'Ed'
	last_name 	= 'Armstrong'
	email 		= 'ghrsst@podaac.jpl.nasa.gov'
	phone 		= '818-393-6710'
	fax 		= '818-393-2718'
	address 	= 'Jet Propulsion Laboratory, 4800 Oak Grove Dr, Pasadena, CA 91109 USA'
printf, fr_id, '<Role>' + role + '</Role> '
printf, fr_id, '<First_Name>' + first_name + '</First_Name> '
printf, fr_id, '<Last_Name>' + last_name + '</Last_Name> '
printf, fr_id, '<Email>' + email + '</Email> '
printf, fr_id, '<Phone>' + phone + '</Phone> '
printf, fr_id, '<Fax>' + fax + '</Fax> '
printf, fr_id, '<Address>' + address + '</Address> '
printf, fr_id, '</Personnel> '
printf, fr_id, '<Metadata_History> '
printf, fr_id, '<FR_File_Version>' + global_atts.product_version + '</FR_File_Version> '
	fr_creation_date = iso_date( systime(/UTC) )
printf, fr_id, '<FR_Creation_Date>' + fr_creation_date + '</FR_Creation_Date> '
	fr_last_revision_date = iso_date( systime(/UTC) )
printf, fr_id, '<FR_Last_Revision_Date>' + fr_last_revision_date + '</FR_Last_Revision_Date> '
printf, fr_id, '<FR_Revision_History>' + global_atts.history + ', ' + systime(/UTC) +  '</FR_Revision_History> '
printf, fr_id, '</Metadata_History> '

	file_compression = 'bzip'
printf, fr_id, '<File_Compression>' + file_compression + '</File_Compression> '
printf, fr_id, '</MMR_FR> '


;close, fr_id
; A better solution is to use free_lun

free_lun, fr_id
;-------------------
; done FR creation
;-------------------
return, o_status
END

; ------------------------------------------------------------
; returns a structure of COARDS GLOBAL attributes from L2P file
; ------------------------------------------------------------
FUNCTION get_global_attributes, nid, file_info

 ; returned structure prototype for GLOBAL attributes
 global_atts = { global_attributes, Conventions:'', title:'', DSD_entry_id:'', references:'', institution:'', $
		       contact:'', GDS_version_id:'', netcdf_version_id:'', creation_date:'', $
		       product_version:'', history:'', platform:'', sensor:'', spatial_resolution:'', $
		       start_date:'', start_time:'', stop_date:'', stop_time:'', northernmost_latitude:0.0, $
		       southernmost_latitude:0.0, westernmost_longitude:0.0, easternmost_longitude:0.0, $
		       file_quality_index:0, comment:'' }  


 ; loop through the global attributes and load into a structure
 for gatt_id=0, file_info.ngatts - 1 do begin
     gatt_name = ncdf_attname( nid, gatt_id, /GLOBAL )

     case gatt_name of
	 'Conventions': begin
             ncdf_attget, nid, 'Conventions', Conventions, /GLOBAL
             global_atts.Conventions = string(Conventions)
          end

	 'DSD_entry_id': begin
             ncdf_attget, nid, 'DSD_entry_id', DSD_entry_id, /GLOBAL
             global_atts.DSD_entry_id = string(DSD_entry_id)
          end

	 'title': begin
             ncdf_attget, nid, 'title', title, /GLOBAL
             global_atts.title = string(title)
          end

	 'references': begin
             ncdf_attget, nid, 'references', references, /GLOBAL
             global_atts.references = string(references)
          end

	 'institution': begin
             ncdf_attget, nid, 'institution', institution, /GLOBAL
             global_atts.institution = string(institution)
          end

	 'contact': begin
             ncdf_attget, nid, 'contact', contact, /GLOBAL
             global_atts.contact = string(contact)
          end

	 'institution': begin
             ncdf_attget, nid, 'institution', institution, /GLOBAL
             global_atts.institution = string(institution)
          end

	 'GDS_version_id': begin
             ncdf_attget, nid, 'GDS_version_id', GDS_version_id, /GLOBAL
             global_atts.GDS_version_id = string(GDS_version_id)
          end

	 'netcdf_version_id': begin
             ncdf_attget, nid, 'netcdf_version_id', netcdf_version_id, /GLOBAL
             global_atts.netcdf_version_id = string(netcdf_version_id)
          end

	 'creation_date': begin
             ncdf_attget, nid, 'creation_date', creation_date, /GLOBAL
             global_atts.creation_date = string(creation_date)
          end

	 'product_version': begin
             ncdf_attget, nid, 'product_version', product_version, /GLOBAL
             global_atts.product_version = string(product_version)
          end

	 'history': begin
             ncdf_attget, nid, 'history', history, /GLOBAL
             global_atts.history = string(history)
          end

	 'platform': begin
             ncdf_attget, nid, 'platform', platform, /GLOBAL
             global_atts.platform = string(platform)
          end

	 'sensor': begin
             ncdf_attget, nid, 'sensor', sensor, /GLOBAL
             global_atts.sensor = string(sensor)
          end

	 'spatial_resolution': begin
             ncdf_attget, nid, 'spatial_resolution', spatial_resolution, /GLOBAL
             global_atts.spatial_resolution = string(spatial_resolution)
          end

	 'start_date': begin
             ncdf_attget, nid, 'start_date', start_date, /GLOBAL
             global_atts.start_date = string(start_date)
          end

	 'start_time': begin
             ncdf_attget, nid, 'start_time', start_time, /GLOBAL
             global_atts.start_time = string(start_time)
          end

	 'stop_date': begin
             ncdf_attget, nid, 'stop_date', stop_date, /GLOBAL
             global_atts.stop_date = string(stop_date)
          end

	 'stop_time': begin
             ncdf_attget, nid, 'stop_time', stop_time, /GLOBAL
             global_atts.stop_time = string(stop_time)
          end

	 'northernmost_latitude': begin
             ncdf_attget, nid, 'northernmost_latitude', northernmost_latitude, /GLOBAL
             global_atts.northernmost_latitude = northernmost_latitude
          end

	 'southernmost_latitude': begin
             ncdf_attget, nid, 'southernmost_latitude', southernmost_latitude, /GLOBAL
             global_atts.southernmost_latitude = southernmost_latitude
          end

	 'westernmost_longitude': begin
             ncdf_attget, nid, 'westernmost_longitude', westernmost_longitude, /GLOBAL
             global_atts.westernmost_longitude = westernmost_longitude
          end

	 'easternmost_longitude': begin
             ncdf_attget, nid, 'easternmost_longitude', easternmost_longitude, /GLOBAL
             global_atts.easternmost_longitude = easternmost_longitude
          end

	 'file_quality_index': begin
             ncdf_attget, nid, 'file_quality_index', file_quality_index, /GLOBAL
             global_atts.file_quality_index = file_quality_index
          end

	 'comment': begin
             ncdf_attget, nid, 'comment', comment, /GLOBAL
             global_atts.comment = string(comment)
          end

	  else: begin
	      print, ' unknown attribute: ',  gatt_name

	  end
     endcase

 endfor

 return, global_atts
END

; -----------------------------------------------------------------
; returns the ISO 8601 date format (YYYYMMDDZHHMMSS)
; from a standard UNIX time stamp (Day Month Month_Day HH:MM:SS Year)
; -----------------------------------------------------------------
FUNCTION iso_date, unix_time_stamp 

    date_string = strsplit( unix_time_stamp, /extract )

    year = date_string[4]

    ; get a numeric month
    case date_string[1] of
	'Jan': month = '01'
	'Feb': month = '02'
	'Mar': month = '03'
	'Apr': month = '04'
	'May': month = '05'
	'Jun': month = '06'
	'Jul': month = '07'
	'Aug': month = '08'
	'Sep': month = '09'
	'Oct': month = '10'
	'Nov': month = '11'
	'Dec': month = '12'
    endcase

    ; get the day of month
    month_day = date_string[2]
    if month_day lt 10 then month_day = '0' + month_day  

    ; UTC time zone
    time_zone = 'Z'

    ; parse hour:min:sec
    hour_min_sec = strsplit( date_string[3], ':', /extract )
    hour = hour_min_sec[0]
    min = hour_min_sec[1]
    sec = hour_min_sec[2]

    ; make the ISO time
    iso_date = year + month + month_day + 'T' + hour + min + sec + time_zone
    return, iso_date
END

PRO usage
    print, " create FR metadata for MODIS L2P"
    print, " USAGE: "
    print, " IDL> make_modisl2p_meta, <L2P_file>
    print, ''
END
