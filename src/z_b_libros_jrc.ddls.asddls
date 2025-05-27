@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZVLIBROS_JRC'

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Libros'

@Metadata.ignorePropagatedAnnotations: true

define view Z_B_LIBROS_JRC
  as select from ztb_libros_jrc

{
  key id_libro  as IdLibro,
  key bi_categ  as BiCateg,

      titulo    as Titulo,
      autor     as Autor,
      editorial as Editorial,
      idioma    as Idioma,
      paginas   as Paginas,
      @Semantics.amount.currencyCode: 'Moneda'
      precio    as Precio,
      @Semantics.currencyCode: true
      moneda    as Moneda,
      formato   as Formato,
      url       as Imagen
}
