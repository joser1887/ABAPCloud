CLASS zcl_delte_table_jrc DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_delte_table_jrc IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM zrent_brands_jrc.
    IF sy-subrc = 0.
      out->write( data = 'All entries in table ZRENT_BRANDS_JRC have been deleted' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
