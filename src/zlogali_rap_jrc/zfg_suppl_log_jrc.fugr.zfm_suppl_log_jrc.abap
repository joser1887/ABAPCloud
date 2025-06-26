FUNCTION zfm_suppl_log_jrc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_SUPPLEMENTS) TYPE  ZTT_SUPPL_LOG_JRC OPTIONAL
*"     VALUE(IV_OP_TYPE) TYPE  ZDE_FLAG_JRC OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_UPDATE) TYPE  ZDE_FLAG_JRC
*"----------------------------------------------------------------------
  CHECK it_supplements IS NOT INITIAL.
  CASE iv_op_type.
    WHEN 'C'.
      INSERT zbooksupp_logjrc FROM TABLE @it_supplements.
    WHEN 'U'.
      UPDATE zbooksupp_logjrc FROM TABLE @it_supplements.
    WHEN 'D'.
      DELETE zbooksupp_logjrc FROM TABLE @it_supplements.

  ENDCASE.
  IF sy-subrc = 0.
    ev_update = abap_true.
  ENDIF.
ENDFUNCTION.
