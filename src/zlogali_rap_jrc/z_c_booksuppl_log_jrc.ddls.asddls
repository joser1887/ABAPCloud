@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Consumption - Booking Supplement'
@Search.searchable: true
@Metadata.allowExtensions: true

define view entity Z_C_BOOKSUPPL_LOG_JRC
  as projection on Z_I_BOOKSUPPL_LOG_JRC

{
  key travel_id                   as TravelID,
      @Search.defaultSearchElement: true
  key booking_id                  as BookingID,
      @Consumption.valueHelpDefinition: [ { entity:            { name:    '/DMO/I_SUPPLEMENT',
                                                                 element: 'SupplementID' },
                                            additionalBinding: [ { localElement: 'Price',
                                                                   element:      'Price' },
                                                                 { localElement: 'CurrencyCode',
                                                                   element:      'CurrencyCode' } ] } ]
  key booking_supplement_id       as BookingSupplementID,

      @ObjectModel.text.element: [ 'SupplementDescription' ]
      supplement_id               as SupplementID,

      _SupplementText.Description as SupplementDescription : localized,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                       as Price,

      @Semantics.currencyCode: true
      @Consumption.valueHelpDefinition: [ { entity: { name:    'I_Currency',
                                                  element: 'Currency' } } ]
      currency_code               as CurrencyCode,

      last_changed_at             as LastChangedAt,
      /* Associations */
      _Travel  : redirected to Z_C_TRAVEL_LOG_jrc,
      _Booking : redirected to parent Z_c_BOOKING_LOG_JRC,

      _Product,
      _SupplementText
}
