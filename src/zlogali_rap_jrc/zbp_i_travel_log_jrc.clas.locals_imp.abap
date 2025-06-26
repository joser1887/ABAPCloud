CLASS lsc_z_i_travel_log_jrc DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PUBLIC SECTION.
    CONSTANTS GC_create TYPE string VALUE 'CREATE'.
    CONSTANTS gc_update TYPE string VALUE 'UPDATE'.
    CONSTANTS gc_delete TYPE string VALUE 'DELETE'.
    CONSTANTS create    TYPE string VALUE 'C'.
    CONSTANTS update    TYPE string VALUE 'U'.
    CONSTANTS Delete    TYPE string VALUE 'D'.

  PROTECTED SECTION.
    METHODS save_modified    REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.


CLASS lsc_z_i_travel_log_jrc IMPLEMENTATION.
  METHOD save_modified.
    DATA lt_travel_log   TYPE STANDARD TABLE OF zlog_log_jrc.
    DATA lt_travel_log_u TYPE STANDARD TABLE OF zlog_log_jrc.
    DATA lt_supplements  TYPE STANDARD TABLE OF zbooksupp_logjrc.
    DATA lv_op_type      TYPE zde_flag_jrc.
    DATA lv_update       TYPE zde_flag_jrc.

    IF create-supplement IS NOT INITIAL.
      lt_supplements = CORRESPONDING #( create-supplement ).
      lv_op_type = me->create.
    ENDIF.
    IF update-supplement IS NOT INITIAL.
      lt_supplements = CORRESPONDING #( update-supplement ).
      lv_op_type = me->update.
    ENDIF.
    IF delete-supplement IS NOT INITIAL.
      lt_supplements = CORRESPONDING #( delete-supplement ).
      lv_op_type = me->delete.
    ENDIF.
    IF lt_supplements IS NOT INITIAL.
      CALL FUNCTION 'ZFM_SUPPL_LOG_JRC'
        EXPORTING it_supplements = lt_supplements
                  iv_op_type     = lv_op_type
        IMPORTING ev_update      = lv_update.
      IF lv_update = abap_true.
*        reported-supplement[ 1 ]
      ENDIF.
    ENDIF.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    IF create-travel IS NOT INITIAL.
      lt_travel_log = CORRESPONDING #( create-travel ).
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<lfs_travel_log>).
        GET TIME STAMP FIELD <lfs_travel_log>-created_at.
        <lfs_travel_log>-changing_operation = me->GC_create.
        READ TABLE create-travel WITH TABLE KEY entity COMPONENTS travel_id = <lfs_travel_log>-travel_id
             INTO DATA(ls_travel).
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF ls_travel-%control-booking_fee = cl_abap_behv=>flag_changed.
          <lfs_travel_log>-changed_field_name = 'booking_fee'.
          <lfs_travel_log>-changed_value      = ls_travel-booking_fee.
          <lfs_travel_log>-user_mod           = lv_user.
          TRY.
              <lfs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.
          APPEND <lfs_travel_log> TO lt_travel_log_u.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF update-travel IS NOT INITIAL.
      lt_travel_log = CORRESPONDING #( update-travel ).
      LOOP AT update-travel INTO ls_travel.
        ASSIGN lt_travel_log[ travel_id = ls_travel-travel_id ] TO <lfs_travel_log>.
        GET TIME STAMP FIELD <lfs_travel_log>-created_at.
        IF ls_travel-%control-customer_id <> cl_abap_behv=>flag_changed.
          CONTINUE.
        ENDIF.

        <lfs_travel_log>-changed_field_name = 'customer_id'.
        <lfs_travel_log>-changed_value      = ls_travel-customer_id.
        <lfs_travel_log>-changing_operation = me->gc_update.
        <lfs_travel_log>-user_mod           = lv_user.
        TRY.
            <lfs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            " handle exception
        ENDTRY.
        APPEND <lfs_travel_log> TO lt_travel_log_u.
      ENDLOOP.
    ENDIF.
    IF delete-travel IS NOT INITIAL.
      lt_travel_log = CORRESPONDING #( delete-travel ).
      LOOP AT lt_travel_log ASSIGNING <lfs_travel_log>.
        GET TIME STAMP FIELD <lfs_travel_log>-created_at.
        <lfs_travel_log>-changing_operation = me->gc_delete.
        <lfs_travel_log>-user_mod           = lv_user.
        TRY.
            <lfs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            " handle exception
        ENDTRY.
        APPEND <lfs_travel_log> TO lt_travel_log_u.
      ENDLOOP.
    ENDIF.
    IF lt_travel_log_u IS NOT INITIAL.
      INSERT zlog_log_jrc FROM TABLE @lt_travel_log_u.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE Travel.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Travel.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS deductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~deductDiscount RESULT result.

    METHODS reCalTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~reCalTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS Resume FOR MODIFY
      IMPORTING keys FOR ACTION Travel~Resume.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS setStatusToOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStatusToOpen.

    METHODS setTravelNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelNumber.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateBookingFee FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBookingFee.

    METHODS validateCurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCurrency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.


CLASS lhc_Travel IMPLEMENTATION.
  METHOD get_instance_features.
    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
         ENTITY Travel
         FIELDS ( travel_id
         overall_status )
         WITH VALUE #( FOR key_row IN keys
                       (  %key = key_row-%key ) )
         RESULT DATA(lt_travel_result).
    result = VALUE #( FOR ls_travel IN lt_travel_result
                      ( %key                 = ls_travel-%key
                        %action-acceptTravel = COND #( WHEN ls_travel-overall_status = 'A'
                                                       THEN if_abap_behv=>fc-o-disabled
                                                       ELSE if_abap_behv=>fc-o-enabled )
                        %assoc-_Booking      = if_abap_behv=>fc-o-enabled
                        %action-rejectTravel = COND #( WHEN ls_travel-overall_status = 'X'
                                                       THEN if_abap_behv=>fc-o-disabled
                                                       ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
    DATA(lv_user) = 'CB9980008278'.
    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) = lv_user
                            THEN if_abap_behv=>auth-allowed
                            ELSE if_abap_behv=>auth-unauthorized ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fls_keys>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<fls_result>).
      <fls_result> = VALUE #( %key                           = <fls_keys>-%key
                              %op-%update                    = lv_auth
                              %delete                        = lv_auth
                              %action-acceptTravel           = lv_auth
                              %action-rejectTravel           = lv_auth
                              %action-createTravelByTemplate = lv_auth ).
*                              %assoc-_Booking                = lv_auth ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
    " re
  ENDMETHOD.

  METHOD precheck_create.
  ENDMETHOD.

  METHOD precheck_update.
  ENDMETHOD.

  METHOD acceptTravel.
    " MODIFY in local mode - BO - Related update
    MODIFY ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
           ENTITY Travel
           UPDATE FIELDS ( overall_status )
           WITH VALUE #( FOR key_row IN keys
                         ( travel_id      = key_row-travel_id
                           overall_status = 'A' ) ) " Accepted
           FAILED failed
           REPORTED reported.
    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
         ENTITY Travel
         FIELDS ( agency_id
                  customer_id
                  begin_date
                  end_date
                  booking_fee
                  total_price
                  currency_code
                  overall_status
                  description
                  created_at
                  created_by
                  last_changed_at
                  last_changed_by )
         WITH VALUE #( FOR key_row IN keys
                       ( travel_id = key_row-travel_id ) )
         RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel
                      ( travel_id = ls_travel-travel_id
                        %param    = ls_travel ) ).
    LOOP AT lt_travel INTO DATA(ls_travel_log).

      APPEND VALUE #( %key = ls_travel_log-%key
                      %msg = new_message( id       = 'Z_MC_TRAVEL_LOG_JRC'
                                          number   = 005
                                          severity = if_abap_behv_message=>severity-success
                                          v1       = |{ ls_travel_log-travel_id ALPHA = OUT }| ) )
             TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD createTravelByTemplate.
    DATA lt_create_travel TYPE TABLE FOR CREATE z_i_travel_log_jrc\\Travel.

    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
         ENTITY Travel
         FIELDS ( travel_id agency_id customer_id booking_fee currency_code )
         WITH VALUE #( FOR row_key IN keys
                       ( %key = row_key-%key ) )
         RESULT DATA(lt_read_entity_travel)
         FAILED failed
         REPORTED reported.
    IF failed IS NOT INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    SELECT MAX( travel_id ) FROM ztravel_log_jrc
      INTO @DATA(lv_travel_id).
    lt_create_travel = VALUE #( FOR crate_row IN lt_read_entity_travel INDEX INTO idx
                                ( travel_id      = lv_travel_id + idx
                                  agency_id      = crate_row-agency_id
                                  customer_id    = crate_row-customer_id
                                  begin_date     = lv_today
                                  end_date       = lv_today + 30
                                  booking_fee    = crate_row-booking_fee
                                  total_price    = crate_row-total_price
                                  currency_code  = crate_row-currency_code
                                  description    = 'Add Comments'
                                  overall_status = '0' ) ).
    MODIFY ENTITIES OF z_i_travel_log_jrc
           IN LOCAL MODE ENTITY Travel
           CREATE FIELDS ( travel_id
                           agency_id
                           customer_id
                           begin_date
                           end_date
                           booking_fee
                           total_price
                           currency_code
                           description
                           overall_status )
           WITH lt_create_travel
           MAPPED mapped
           FAILED failed
           REPORTED reported.
    result = VALUE #( FOR result_row IN lt_create_travel INDEX INTO idx
                      ( %cid_ref = keys[ idx ]-%cid_ref
                        %key     = keys[ idx ]-%key
                        %param   = CORRESPONDING #( result_row ) ) ).
  ENDMETHOD.

  METHOD deductDiscount.
  ENDMETHOD.

  METHOD reCalTotalPrice.
*    IF keys IS NOT INITIAL.
*      zcl_aux_travel_det_log_jrc=>calculate_price( it_travel = VALUE #( FOR GROUPS <booking> OF booking_key IN keys
*                                                                        GROUP BY booking_key-travel_id WITHOUT MEMBERS
*                                                                        ( <booking> ) )
*                                                   is_draft  = keys[ 1 ]-%is_draft ).
*
*    ENDIF.
TYPES: BEGIN OF ty_amount_per_currencycode,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currencycode.

    DATA: amount_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

    " Read all relevant travel instances.
    READ ENTITIES OF Z_I_TRAVEL_LOG_JRC IN LOCAL MODE
         ENTITY Travel
            FIELDS ( booking_fee currency_code )
            WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    DELETE travels WHERE currency_code IS INITIAL.

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      " Set the start for the calculation by adding the booking fee.
      amount_per_currencycode = VALUE #( ( amount        = <travel>-booking_fee
                                           currency_code = <travel>-currency_code ) ).

      " Read all associated bookings and add them to the total price.
      READ ENTITIES OF Z_I_TRAVEL_LOG_JRC IN LOCAL MODE
        ENTITY Travel BY \_Booking
          FIELDS ( flight_price currency_code )
        WITH VALUE #( ( %tky = <travel>-%tky ) )
        RESULT DATA(bookings).

      LOOP AT bookings INTO DATA(booking) WHERE currency_code IS NOT INITIAL.
        COLLECT VALUE ty_amount_per_currencycode( amount        = booking-flight_price
                                                  currency_code = booking-currency_code ) INTO amount_per_currencycode.
      ENDLOOP.

      " Read all associated booking supplements and add them to the total price.
      READ ENTITIES OF Z_I_TRAVEL_LOG_JRC IN LOCAL MODE
        ENTITY Booking BY \_BookingSupplement
          FIELDS ( price currency_code )
        WITH VALUE #( FOR rba_booking IN bookings ( %tky = rba_booking-%tky ) )
        RESULT DATA(bookingsupplements).

      LOOP AT bookingsupplements INTO DATA(bookingsupplement) WHERE currency_code IS NOT INITIAL.
        COLLECT VALUE ty_amount_per_currencycode( amount        = bookingsupplement-price
                                                  currency_code = bookingsupplement-currency_code ) INTO amount_per_currencycode.
      ENDLOOP.

      CLEAR <travel>-total_price.
      LOOP AT amount_per_currencycode INTO DATA(single_amount_per_currencycode).
        " If needed do a Currency Conversion
        IF single_amount_per_currencycode-currency_code = <travel>-currency_code.
          <travel>-total_price += single_amount_per_currencycode-amount.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
             EXPORTING
               iv_amount                   =  single_amount_per_currencycode-amount
               iv_currency_code_source     =  single_amount_per_currencycode-currency_code
               iv_currency_code_target     =  <travel>-currency_code
               iv_exchange_rate_date       =  cl_abap_context_info=>get_system_date( )
             IMPORTING
               ev_amount                   = DATA(total_booking_price_per_curr)
            ).
          <travel>-total_price += total_booking_price_per_curr.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " write back the modified total_price of travels
    MODIFY ENTITIES OF Z_I_TRAVEL_LOG_JRC IN LOCAL MODE
      ENTITY travel
        UPDATE FIELDS ( total_price )
        WITH CORRESPONDING #( travels ).
  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
           ENTITY Travel
           UPDATE FIELDS ( overall_status )
           WITH VALUE #( FOR key_row IN keys
                         ( travel_id      = key_row-travel_id
                           overall_status = 'X' ) ) " Accepted
           FAILED failed
           REPORTED reported.
    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
         ENTITY Travel
         FIELDS ( agency_id
                  customer_id
                  begin_date
                  end_date
                  booking_fee
                  total_price
                  currency_code
                  overall_status
                  description
                  created_at
                  created_by
                  last_changed_at
                  last_changed_by )
         WITH VALUE #( FOR key_row IN keys
                       ( travel_id = key_row-travel_id ) )
         RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel
                      ( travel_id = ls_travel-travel_id
                        %param    = ls_travel ) ).
    LOOP AT lt_travel INTO DATA(ls_travel_log).

      APPEND VALUE #( %key = ls_travel_log-%key
                      %msg = new_message( id       = 'Z_MC_TRAVEL_LOG_JRC'
                                          number   = 006
                                          severity = if_abap_behv_message=>severity-success
                                          v1       = |{ ls_travel_log-travel_id ALPHA = OUT }| ) )
             TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD Resume.
  ENDMETHOD.

  METHOD calculateTotalPrice.
    MODIFY ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
           ENTITY Travel
           EXECUTE reCalTotalPrice
           FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD setStatusToOpen.
  ENDMETHOD.

  METHOD setTravelNumber.
  ENDMETHOD.

  METHOD validateAgency.
  ENDMETHOD.

  METHOD validateBookingFee.
  ENDMETHOD.

  METHOD validateCurrency.
  ENDMETHOD.

  METHOD validateCustomer.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
         ENTITY Travel
         FIELDS ( customer_id )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel).
    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = customer_id EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.
    SELECT FROM /dmo/customer
      FIELDS customer_id
      FOR ALL ENTRIES IN @lt_travel
      WHERE customer_id = @lt_travel-customer_id
      INTO TABLE @DATA(lt_customer_bd).
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      IF        <fs_travel>-customer_id IS INITIAL
         OR NOT line_exists( lt_customer_bd[ customer_id = <fs_travel>-customer_id ] ).
        APPEND VALUE #( travel_id = <fs_travel>-travel_id ) TO failed-travel.
        APPEND VALUE #( travel_id            = <fs_travel>-travel_id
                        %msg                 = new_message( id       = 'Z_MC_TRAVEL_LOG_JRC'
                                                            number   = 001
                                                            severity = if_abap_behv_message=>severity-error
                                                            v1       = <fs_travel>-customer_id )
                        %element-customer_id = if_abap_behv=>mk-on )
               TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
         ENTITY Travel
         FIELDS ( begin_date end_date )
         WITH VALUE #( FOR <row_key> IN keys
                       ( %key = <row_key>-%key ) )
         RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      IF ls_travel_result-end_date < ls_travel_result-begin_date.

        APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.
        APPEND VALUE #(
            %key                = ls_travel_result-%key
            %msg                = new_message( id       = 'Z_MC_TRAVEL_LOG_JRC'
                                               number   = 002
                                               severity = if_abap_behv_message=>severity-error
                                               v1       = |{ ls_travel_result-begin_date DATE = ENVIRONMENT }|
                                               v2       = |{ ls_travel_result-end_date DATE = ENVIRONMENT }|
                                               v3       = ls_travel_result-travel_id )
            %element-begin_date = if_abap_behv=>mk-on
            %element-end_date   = if_abap_behv=>mk-on )
               TO reported-travel.
      ELSEIF ls_travel_result-begin_date < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.
        APPEND VALUE #( %key                = ls_travel_result-%key
                        %msg                = new_message( id       = 'Z_MC_TRAVEL_LOG_JRC'
                                                           number   = 003
                                                           severity = if_abap_behv_message=>severity-error
                                                           v1       = ls_travel_result-begin_date )
                        %element-begin_date = if_abap_behv=>mk-on )
               TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
         ENTITY Travel
         FIELDS ( begin_date end_date )
         WITH VALUE #( FOR <row_key> IN keys
                       ( %key = <row_key>-%key ) )
         RESULT DATA(lt_travel_result).
    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      CASE ls_travel_result-overall_status.
        WHEN 'O'.
        WHEN 'X'.
        WHEN 'A'.
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.
          APPEND VALUE #( %key                = ls_travel_result-%key
                          %msg                = new_message( id       = 'Z_MC_TRAVEL_LOG_JRC'
                                                             number   = 004
                                                             severity = if_abap_behv_message=>severity-error
                                                             v1       = |{ ls_travel_result-travel_id ALPHA = OUT }| )
                          %element-begin_date = if_abap_behv=>mk-on )
                 TO reported-travel.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
