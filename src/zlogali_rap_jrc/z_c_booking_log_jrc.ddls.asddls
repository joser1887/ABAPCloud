@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Consumption - Booking'

@Metadata.allowExtensions: true

@Search.searchable: true

define view entity Z_c_BOOKING_LOG_JRC
  as projection on Z_I_BOOKING_LOG_JRC

{
      @Search.defaultSearchElement: true
  key travel_id          as TravelID,

      @Search.defaultSearchElement: true
  key booking_id         as BookingID,

      booking_date       as BookingDate,

      @Consumption.valueHelpDefinition: [ { entity: { name:    '/DMO/I_Customer',
                                                      element: 'CustomerID' } } ]
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Search.defaultSearchElement: true
      customer_id        as CustomerID,

      _Customer.LastName as CustomerName,

      @Consumption.valueHelpDefinition: [ { entity: { name:    '/DMO/I_Carrier',
                                                      element: 'AirlineID' } } ]
      @ObjectModel.text.element: [ 'CarrierName' ]
      carrier_id         as CarrierID,

      _Carrier.Name      as CarrierName,

      @Consumption.valueHelpDefinition: [ { entity:            { name:    '/DMO/I_Flight',
                                                                 element: 'ConnectionID' },
                                            additionalBinding: [ { localElement: 'FlightDate',
                                                                   element:      'FlightDate' },
                                                                 { localElement: 'CarrierID',
                                                                   element:      'AirlineID' },
                                                                 { localElement: 'FlightPrice',
                                                                   element:      'Price' },
                                                                 { localElement: 'CurrencyCode',
                                                                   element:      'CurrencyCode' } ] } ]
      connection_id      as ConnectionID,

      @Consumption.valueHelpDefinition: [ { entity:            { name:    '/DMO/I_Flight',
                                                                 element: 'FlightDate' },
                                            additionalBinding: [ { localElement: 'ConnectionID',
                                                                   element:      'ConnectionID' },
                                                                 { localElement: 'CarrierID',
                                                                   element:      'AirlineID' },
                                                                 { localElement: 'FlightPrice',
                                                                   element:      'Price' },
                                                                 { localElement: 'CurrencyCode',
                                                                   element:      'CurrencyCode' } ] } ]
      flight_date        as FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price       as FlightPrice,

      @Consumption.valueHelpDefinition: [ { entity: { name:    'I_Currency',
                                                      element: 'Currency' } } ]
      @Semantics.currencyCode: true
      currency_code      as CurrencyCode,

      booking_status     as BookingStatus,
      last_change_at     as LastChangedAt,
      /* Associations */
      _Travel : redirected to parent Z_C_TRAVEL_LOG_jrc,
      _BookingSupplement : redirected to composition child Z_C_BOOKSUPPL_LOG_JRC,

      _Carrier,
      _Connection,
      _Customer
}
