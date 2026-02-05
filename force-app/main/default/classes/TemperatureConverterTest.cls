/**
 * @description Test class for TemperatureConverter
 */
@IsTest
private class TemperatureConverterTest {
    /**
     * @description Test method for fahrenheitToCelsius
     */
    @IsTest
    static void testFahrenheitToCelsius() {
        // Test case 1: Freezing point of water
        Decimal fahrenheit1 = 32;
        Decimal expectedCelsius1 = 0;
        Decimal actualCelsius1 = TemperatureConverter.fahrenheitToCelsius(fahrenheit1);
        System.assertEquals(expectedCelsius1, actualCelsius1, 'Incorrect conversion for freezing point');
        
        // Test case 2: Boiling point of water
        Decimal fahrenheit2 = 212;
        Decimal expectedCelsius2 = 100;
        Decimal actualCelsius2 = TemperatureConverter.fahrenheitToCelsius(fahrenheit2);
        System.assertEquals(expectedCelsius2, actualCelsius2, 'Incorrect conversion for boiling point');
        
        // Test case 3: Room temperature
        Decimal fahrenheit3 = 68;
        Decimal expectedCelsius3 = 20;
        Decimal actualCelsius3 = TemperatureConverter.fahrenheitToCelsius(fahrenheit3);
        System.assertEquals(expectedCelsius3, actualCelsius3, 'Incorrect conversion for room temperature');
        
        // Test case 4: Negative temperature
        Decimal fahrenheit4 = -40;
        Decimal expectedCelsius4 = -40;
        Decimal actualCelsius4 = TemperatureConverter.fahrenheitToCelsius(fahrenheit4);
        System.assertEquals(expectedCelsius4, actualCelsius4, 'Incorrect conversion for negative temperature');
        
        // Test case 5: Decimal precision
        Decimal fahrenheit5 = 98.6;
        Decimal expectedCelsius5 = 37.00;
        Decimal actualCelsius5 = TemperatureConverter.fahrenheitToCelsius(fahrenheit5);
        System.assertEquals(expectedCelsius5, actualCelsius5, 'Incorrect conversion or precision for body temperature');
    }

    /**
     * @description Test method for null input
     */
    @IsTest
    static void testNullInput() {
        try {
            TemperatureConverter.fahrenheitToCelsius(null);
            System.assert(false, 'IllegalArgumentException was expected');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Input temperature cannot be null', e.getMessage(), 'Incorrect exception message');
        }
    }
}