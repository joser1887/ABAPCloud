@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZVVEN_LIB_JR'

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Libros Venddidos a los clientes'

@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view Z_B_VEN_LIB_JR
  as select from ztb_clnts_lib_jr

{
  key id_libro                   as IdLibro,

      count(distinct id_cliente) as ventas
}

group by id_libro
