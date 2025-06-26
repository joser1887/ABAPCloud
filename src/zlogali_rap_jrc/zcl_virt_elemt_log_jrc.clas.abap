CLASS zcl_virt_elemt_log_jrc DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
ENDCLASS.


CLASS zcl_virt_elemt_log_jrc IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity = 'Z_C_TRAVEL_LOG_JRC'.
      LOOP AT it_requested_calc_elements INTO DATA(ls_calc_elements).
        IF ls_calc_elements = 'DISCOUNTPRICE'.
          APPEND 'TOTALPRICE' TO et_requested_orig_elements.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF z_c_travel_log_jrc WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<lfs_original_data>).
      <lfs_original_data>-DiscountPrice = <lfs_original_data>-TotalPrice * ( 1 - ( 1 / 10 ) ).
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.
ENDCLASS.
