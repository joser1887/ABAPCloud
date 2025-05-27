@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZV_CLIENTES_JRC'

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Clientes'

@Metadata.ignorePropagatedAnnotations: true

define view Z_B_CLIENTES_JRC
  as select from ztb_clientes_jrc

{
  key id_cliente                              as IdCliente,
  key tipo_acceso                             as TipoAcceso,

      concat_with_space(nombre, apellidos, 1) as Nombre,
      email                                   as Email,
      url                                     as Url
}
