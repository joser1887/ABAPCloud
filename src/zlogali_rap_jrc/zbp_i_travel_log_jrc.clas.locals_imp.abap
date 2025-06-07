CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

ENDCLASS.


CLASS lhc_Travel IMPLEMENTATION.
  METHOD get_instance_features.
    READ ENTITIES OF z_i_travel_log_jrc
         ENTITY Travel
         FIELDS ( travel_id
         overall_status )
         WITH VALUE #( FOR key_row IN keys
                       (  %key = key_row-%key ) )
         RESULT DATA(lt_travel_result).
    result = VALUE #( FOR ls_travel IN lt_travel_result
                      ( %key                  = ls_travel-%key
                        %field-travel_id      = if_abap_behv=>fc-f-read_only
                        %field-overall_status = if_abap_behv=>fc-f-read_only
                        %action-acceptTravel  = COND #( WHEN ls_travel-overall_status = 'A'
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled )
                        %action-rejectTravel  = COND #( WHEN ls_travel-overall_status = 'X'
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
                              %action-createTravelByTemplate = lv_auth
                              %assoc-_Booking                = lv_auth ).
    ENDLOOP.
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

    READ ENTITIES OF z_i_travel_log_jrc
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


CLASS lsc_Z_I_TRAVEL_LOG_JRC DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified    REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.


CLASS lsc_Z_I_TRAVEL_LOG_JRC IMPLEMENTATION.
  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
