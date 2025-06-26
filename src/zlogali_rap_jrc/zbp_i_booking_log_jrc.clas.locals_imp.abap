CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    TYPES tt_travel_id TYPE TABLE OF /dmo/travel_id.

  PRIVATE SECTION.
    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR booking RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR booking RESULT result.

    METHODS setbookingdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR booking~setbookingdate.

    METHODS setbookingnumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR booking~setbookingnumber.

    METHODS validateconnection FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validateconnection.

    METHODS validatecurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatecurrency.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatecustomer.

    METHODS validateflightprices FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validateflightprices.
    METHODS calculatetotalsupplimprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~calculatetotalsupplimprice.

ENDCLASS.


CLASS lhc_Booking IMPLEMENTATION.
  METHOD calculateTotalFlightPrice.
    " Read all parent UUIDs
    READ ENTITIES OF Z_I_TRAVEL_LOG_JRC IN LOCAL MODE
      ENTITY Booking BY \_Travel
        FIELDS ( travel_id  )
        WITH CORRESPONDING #(  keys  )
      RESULT DATA(travels).

    " Trigger Re-Calculation on Root Node
    MODIFY ENTITIES OF Z_I_TRAVEL_LOG_JRC IN LOCAL MODE
      ENTITY Travel
        EXECUTE reCalTotalPrice
          FROM CORRESPONDING  #( travels ).
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
        WHEN 'N'. " New
        WHEN 'X'. " Cancel
        WHEN 'B'. " Booked
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_booking_result-%key ) TO failed-booking.
          APPEND VALUE #(
              %key                    = ls_booking_result-%key
              %msg                    = new_message( id       = 'Z_MC_TRAVEL_LOG_JRC'
                                                     number   = 007
                                                     severity = if_abap_behv_message=>severity-error
                                                     v1       = |{ ls_booking_result-booking_id ALPHA = OUT }| )
              %element-booking_status = if_abap_behv=>mk-on )
                 TO reported-booking.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
         ENTITY Booking
         FIELDS ( booking_id booking_date customer_id booking_status )
         WITH VALUE #( FOR keyval IN keys
                       ( %key = keyval-%key ) )
         RESULT DATA(lt_booking_result).
    result = VALUE #( FOR ls_travel IN lt_booking_result
                      ( %key                      = ls_travel-%key
                        %assoc-_BookingSupplement = if_abap_behv=>fc-o-enabled ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setBookingDate.
  ENDMETHOD.

  METHOD setBookingNumber.
  ENDMETHOD.

  METHOD validateConnection.
  ENDMETHOD.

  METHOD validateCurrency.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateFlightPrices.
  ENDMETHOD.
  METHOD calculateTotalSupplimPrice.
  ENDMETHOD.

ENDCLASS.
