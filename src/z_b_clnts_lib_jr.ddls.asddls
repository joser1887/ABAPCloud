@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZVCLNTS_LIB_JR'

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Libros Venddidos a los clientes'

@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
define view Z_B_CLNTS_LIB_JR
  as select from ztb_clnts_lib_jr as CLI_LIB

  association [1] to Z_B_LIBROS_JRC   as _Libros  on _Libros.IdLibro = $projection.IdLibro
  association [1] to Z_B_CLIENTES_JRC as _cliente on _cliente.IdCliente = $projection.IdCliente

{
      @ObjectModel.text.element: [ 'Titulo' ]
  key id_libro        as IdLibro,

      @ObjectModel.text.element: [ 'Nombre' ]
  key id_cliente      as IdCliente,

      _Libros.Titulo  as Titulo,
      _cliente.Nombre as Nombre,
      _cliente.TipoAcceso,
      _cliente.Email,
      _cliente.Url,
      _Libros,
      _cliente
}
