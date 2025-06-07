CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

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
    result = VALUE #(
        FOR ls_travel IN lt_travel_result
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
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateDates.
  ENDMETHOD.

  METHOD validateStatus.
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
