CLASS zcl_aux_travel_det_log_jrc DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES tt_travel_reported     TYPE TABLE FOR REPORTED z_i_travel_log_jrc.
    TYPES tt_booking_reported    TYPE TABLE FOR REPORTED z_i_booking_log_jrc.
    TYPES tt_supplement_reported TYPE TABLE FOR REPORTED z_i_booksuppl_log_jrc.
    TYPES tt_travel_id           TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS calculate_price IMPORTING it_travel TYPE tt_travel_id
                                            is_draft  TYPE abp_behv_flag OPTIONAL.

*    EXPORTING et_travel_report TYPE tt_travel_reported.
ENDCLASS.


CLASS zcl_aux_travel_det_log_jrc IMPLEMENTATION.
  METHOD calculate_price.
**    DATA lv_total_booking_price TYPE /dmo/total_price.
**    DATA lv_total_suppl_price   TYPE /dmo/total_price.
**
**    IF it_travel IS INITIAL.
**      RETURN.
**    ENDIF.
**    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
**
**         ENTITY Travel
**         FIELDS ( travel_id currency_code )
**         WITH VALUE #( FOR lv_travel_id IN it_travel
**                       ( travel_id = lv_travel_id ) )
**         RESULT DATA(lt_read_travel).
**
**    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
**         ENTITY Travel BY \_Booking
**         FROM VALUE #( FOR lv_travel_id IN it_travel
**                       ( travel_id              = lv_travel_id
**                         %is_draft              = is_draft
**                         %control-flight_price  = if_abap_behv=>mk-on
**                         %control-currency_code = if_abap_behv=>mk-on ) )
**         RESULT DATA(lt_read_booking).
**    LOOP AT lt_read_booking INTO DATA(ls_booking)
**         GROUP BY ls_booking-travel_id INTO DATA(lv_travel_key).
**      ASSIGN lt_read_travel[ KEY entity COMPONENTS travel_id = lv_travel_key ]
**             TO FIELD-SYMBOL(<ls_travel>).
**      LOOP AT GROUP lv_travel_key INTO DATA(ls_booking_result)
**           GROUP BY ls_booking_result-currency_code INTO DATA(lv_curr).
**        lv_total_booking_price = 0.
**        LOOP AT GROUP lv_curr INTO DATA(ls_booking_line).
**          lv_total_booking_price += ls_booking_line-flight_price.
**        ENDLOOP.
**        IF lv_curr = <ls_travel>-currency_code.
**          <ls_travel>-total_price += lv_total_booking_price.
**        ELSE.
**          /dmo/cl_flight_amdp=>convert_currency(
**            EXPORTING iv_amount               = lv_total_booking_price
**                      iv_currency_code_source = lv_curr
**                      iv_currency_code_target = <ls_travel>-currency_code
**                      iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
**            IMPORTING ev_amount               = DATA(lv_amount_converted) ).
**          IF lv_amount_converted = 0.
**            <ls_travel>-total_price += lv_total_booking_price.
**          ELSE.
**            <ls_travel>-total_price += lv_amount_converted.
**          ENDIF.
**        ENDIF.
**      ENDLOOP.
**    ENDLOOP.
**    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
**         ENTITY Booking BY \_BookingSupplement
**         FROM VALUE #( FOR ls_travel IN lt_read_booking
**                       ( travel_id              = ls_travel-travel_id
**                         booking_id             = ls_travel-booking_id
**                         %is_draft              = is_draft
**                         %control-price         = if_abap_behv=>mk-on
**                         %control-currency_code = if_abap_behv=>mk-on ) )
**         RESULT DATA(lt_read_supplements).
**    LOOP AT lt_read_supplements INTO DATA(ls_booking_suppl)
**         GROUP BY ls_booking_suppl-travel_id INTO lv_travel_key.
**      ASSIGN lt_read_travel[ KEY entity COMPONENTS travel_id = lv_travel_key ] TO <ls_travel>.
**      LOOP AT GROUP lv_travel_key INTO DATA(ls_supplements_result)
**           GROUP BY ls_supplements_result-currency_code INTO lv_curr.
**        lv_total_suppl_price = 0.
**        LOOP AT GROUP lv_curr INTO DATA(ls_supplement_line).
**          lv_total_suppl_price += ls_supplement_line-price.
**        ENDLOOP.
**        IF lv_curr = <ls_travel>-currency_code.
**          <ls_travel>-total_price += lv_total_suppl_price.
**        ELSE.
**          /dmo/cl_flight_amdp=>convert_currency(
**            EXPORTING iv_amount               = lv_total_suppl_price
**                      iv_currency_code_source = lv_curr
**                      iv_currency_code_target = <ls_travel>-currency_code
**                      iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
**            IMPORTING ev_amount               = lv_amount_converted ).
**          IF lv_amount_converted = 0.
**            <ls_travel>-total_price += lv_total_suppl_price.
**          ELSE.
**            <ls_travel>-total_price += lv_amount_converted.
**          ENDIF.
**        ENDIF.
**      ENDLOOP.
**    ENDLOOP.
**    MODIFY ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
**           ENTITY Travel
**           UPDATE FROM VALUE #( FOR ls_travel_bo IN lt_read_travel
**                                ( travel_id            = ls_travel_bo-travel_id
**                                  total_price          = ls_travel_bo-total_price
**                                  %is_draft            = is_draft
**                                  %control-total_price = if_abap_behv=>mk-on ) )
**                                  " TODO: variable is assigned but never used (ABAP cleaner)
**           FAILED DATA(lt_failed) REPORTED DATA(lt_reported).
***    et_travel_report[ 1 ]
    TYPES: BEGIN OF ty_amount_per_currencycode,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currencycode.

    DATA: amount_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

    " Read all relevant travel instances.
    READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
         ENTITY Travel
            FIELDS ( booking_fee currency_code )
            WITH VALUE #( FOR lv_travel_id IN it_travel
                       ( travel_id = lv_travel_id ) )
         RESULT DATA(travels).

    DELETE travels WHERE currency_code IS INITIAL.

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      " Set the start for the calculation by adding the booking fee.
      amount_per_currencycode = VALUE #( ( amount        = <travel>-booking_fee
                                           currency_code = <travel>-currency_code ) ).

      " Read all associated bookings and add them to the total price.
      READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
        ENTITY Travel BY \_Booking
          FIELDS ( flight_price currency_code )
        WITH VALUE #( ( %tky = <travel>-%tky
                        %is_draft = is_draft ) )
        RESULT DATA(bookings).

      LOOP AT bookings INTO DATA(booking) WHERE currency_code IS NOT INITIAL.
        COLLECT VALUE ty_amount_per_currencycode( amount        = booking-flight_price
                                                  currency_code = booking-currency_code ) INTO amount_per_currencycode.
      ENDLOOP.

      " Read all associated booking supplements and add them to the total price.
      READ ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
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
    MODIFY ENTITIES OF z_i_travel_log_jrc IN LOCAL MODE
      ENTITY travel
        UPDATE FIELDS ( total_price )
        WITH CORRESPONDING #( travels ).
  ENDMETHOD.
ENDCLASS.
