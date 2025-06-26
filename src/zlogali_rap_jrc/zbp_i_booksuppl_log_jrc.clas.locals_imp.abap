CLASS lhc_Supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS calculateTotalSupplPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~calculateTotalSupplPrice.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Supplement RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Supplement RESULT result.

    METHODS setBookSupplNumber FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~setBookSupplNumber.

    METHODS validateCurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Supplement~validateCurrency.

    METHODS validatePrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR Supplement~validatePrice.

    METHODS validateSupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR Supplement~validateSupplement.

ENDCLASS.


CLASS lhc_Supplement IMPLEMENTATION.
  METHOD calculateTotalSupplPrice.
    " Read all parent UUIDs
    READ ENTITIES OF Z_I_TRAVEL_LOG_JRC IN LOCAL MODE
      ENTITY Supplement BY \_Travel
        FIELDS ( travel_id  )
        WITH CORRESPONDING #(  keys  )
      RESULT DATA(travels).

    " Trigger Re-Calculation on Root Node
    MODIFY ENTITIES OF Z_I_TRAVEL_LOG_JRC IN LOCAL MODE
      ENTITY Travel
        EXECUTE reCalTotalPrice
          FROM CORRESPONDING  #( travels ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setBookSupplNumber.
  ENDMETHOD.

  METHOD validateCurrency.
  ENDMETHOD.

  METHOD validatePrice.
  ENDMETHOD.

  METHOD validateSupplement.
  ENDMETHOD.
ENDCLASS.
