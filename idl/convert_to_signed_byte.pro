;  Copyright 2006, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: convert_to_signed_byte.pro,v 1.2 2006/09/06 22:19:29 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
; New Request #xxxx

; Function convert an unsigned byte array to a signed byte array.
; It also "correct" the offset from -19.0 to 0.2

; Assumption: array is 2 dimensional and it is of byte size.

FUNCTION convert_to_signed_byte, i_signed_variable_in_byte, ir_offset, o_signed_variable_in_int

r_status = 0;

; Uncomment if want to do nothing.
 
;return, r_status

TO_BYTE_CONVERSION_SUBTRACT    = 128B;

; Get the dimensions of the array.

size_array = size(i_signed_variable_in_byte);

num_columns = size_array[1];
num_rows    = size_array[2];

;
; Do the conversion.  Note the returned array is of type integer.
;

o_signed_variable_in_int = i_signed_variable_in_byte - TO_BYTE_CONVERSION_SUBTRACT;

;
; Correct the offset for signed byte variable.
; The formula is:
;
;            new_offset = old_offset - (128.0 * .15D) 
;

; Save the original offset.

original_offset = ir_offset;

; Use the D to force the multiplication to do it in double.

ir_offset = original_offset - (-128.0 * .15D);

;print, 'convert_to_signed_byte:Correcting offset from ', original_offset, ' to ', ir_offset;

return, r_status
end