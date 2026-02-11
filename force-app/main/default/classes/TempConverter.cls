/**
 * @description Class to convert temperatures between Fahrenheit and Celsius
 */
public with sharing class TempConverter {
    /**
     * @description Converts Fahrenheit temperature to Celsius
     * @param fh Fahrenheit temperature
     * @return Celsius temperature
     */
    public static Decimal fahrenheitToCelsius(Decimal fh) {
        if (fh == null) {
            throw new IllegalArgumentException('Input temperature cannot be null');
        }
        Decimal cs = (fh - 32) * 5/9;
        return cs.setScale(2);
    }
}