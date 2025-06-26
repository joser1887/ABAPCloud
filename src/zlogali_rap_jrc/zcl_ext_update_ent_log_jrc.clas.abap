CLASS zcl_ext_update_ent_log_jrc DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_ext_update_ent_log_jrc IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    MODIFY ENTITIES OF z_i_travel_log_jrc
           ENTITY Travel
           UPDATE FIELDS ( agency_id description )
           WITH VALUE #( ( travel_id   = '00000017'
                           agency_id   = '070049'
                           description = 'Cambio Externo' ) )
           FAILED DATA(failed)
           " TODO: variable is assigned but never used (ABAP cleaner)
           REPORTED DATA(reported).
    READ ENTITIES OF z_i_travel_log_jrc
         ENTITY Travel
         FIELDS ( agency_id description )
         WITH VALUE #( ( travel_id = '00000017' ) )
         " TODO: variable is assigned but never used (ABAP cleaner)
         RESULT DATA(lt_travel_data)
         FAILED failed
         REPORTED reported.
    COMMIT ENTITIES.
    IF failed IS INITIAL.
      out->write( 'Commit Correcto' ).
    ELSE.
      out->write( 'Commit Errado' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
