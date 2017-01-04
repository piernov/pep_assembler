/**
 * Printer classes, prints a uint8_t in hexadecimal, binary or raw character.
 *
 * piernov <piernov@piernov.org>
 */

#include "printer.h"
#include <bitset>
#include <iomanip>
#include <iostream>

void LogisimPrinter::printHeader() {
	std::cout << "v2.0 raw" << std::endl;
}

void LogisimPrinter::print(uint8_t c) {
	std::cout << std::hex // Set hexadecimal print mode
		<< static_cast<int>(c) // Cast to integer for proper printing
		<< " "; // Print separator
}

void HexPrinter::print(uint8_t c) {
	std::cout /*<< "0x"*/ // Print hexadecimal prefix
		<< std::hex // Set hexadecimal print mode
		<< std::setfill('0') // Fill with 0
		<< std::setw(2) // Set width to 2 hexadecimal characters (8-bit integer)
		<< static_cast<int>(c) // Cast to integer for proper printing
		<< " "; // Print separator
}

void BinPrinter::print(uint8_t c) {
	std::bitset<8> bs(c); // Declares a 8-bit wide bitset to get the pretty-printing
	std::cout << bs << " "; // Prints the bitset and a separator
}

void CharPrinter::print(uint8_t c) {
	std::cout << static_cast<unsigned char>(c); // Print the character-casted integer
}
