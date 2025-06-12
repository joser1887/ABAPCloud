CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.
  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
         ENTITY Booking
         FIELDS ( booking_status )
         WITH VALUE #( FOR <row_key> IN keys
                       ( %key = <row_key>-%key ) )
         RESULT DATA(lt_booking_result).
    LOOP AT lt_booking_result INTO DATA(ls_booking_result).
      CASE ls_booking_result-booking_status.
        WHEN 'N'. "New
        WHEN 'X'. "Cancel
        WHEN 'B'. "Booked
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_booking_result-%key ) TO failed-booking.
          APPEND VALUE #( %key                = ls_booking_result-%key
                          %msg                = new_message( id       = 'Z_MC_TRAVEL_LOG_JRC'
                                                             number   = 007
                                                             severity = if_abap_behv_message=>severity-error
                                                             v1       = |{ ls_booking_result-booking_id ALPHA = OUT }| )
                          %element-booking_status = if_abap_behv=>mk-on )
                 TO reported-booking.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
