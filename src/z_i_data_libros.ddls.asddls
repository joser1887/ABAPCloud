@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZV_DALIBROS_JRC'

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Datos de Libros'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

define view Z_I_DATA_LIBROS
  as select from Z_B_LIBROS_JRC as libro

  association [0..*] to Z_B_CLNTS_LIB_JR as _CLI_VEN on _CLI_VEN.IdLibro = $projection.IdLibro
  association [0..1] to Z_B_VEN_LIB_JR   as _Ventas  on _Ventas.IdLibro = $projection.IdLibro
  association [1] to    Z_B_CATEGO_JRC   as _Cat     on _Cat.BiCateg = $projection.BiCateg

{
      @ObjectModel.text.element: [ 'Titulo' ]
  key IdLibro,

      @ObjectModel.text.element: [ 'DesCat' ]
  key BiCateg,

      Titulo,
      _Cat.Descripcion as DesCat,
      Autor,
      Editorial,
      Idioma,
      Paginas,

      @Semantics.amount.currencyCode: 'Moneda'
      Precio           as Precio,

      @Semantics.currencyCode: true
      Moneda,

      Formato,
      Imagen,

      // 0 neutral grey
      // 1 negative red
      // 2 critical yellow
      // 3 positive green
      case
          when _Ventas.ventas < 1 then 0
          when _Ventas.ventas >= 1 and _Ventas.ventas < 2 then 1
          when _Ventas.ventas >= 2 and _Ventas.ventas < 3 then 2
          else 3
        end            as Ventas,

      ''               as Estado,

      _CLI_VEN,
      _Cat
}
