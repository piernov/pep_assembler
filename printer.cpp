#include "printer.h"
#include <bitset>
#include <iomanip>
#include <iostream>

void HexPrinter::print(uint8_t c) {
	std::cout << "0x" << std::hex << std::setfill('0') << std::setw(2) << static_cast<int>(c) << " ";
}

void BinPrinter::print(uint8_t c) {
	std::bitset<8> bs(c);
	std::cout << bs << " ";
}

void CharPrinter::print(uint8_t c) {
	std::cout << (unsigned char) c;
}
