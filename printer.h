/**
 * Printer classes, prints a uint8_t in hexadecimal, binary or raw character.
 *
 * piernov <piernov@piernov.org>
 */

#include <cstdint>

// Printer superclass, for polymorphism
class Printer {
public:
	// Actual printing function
	virtual void print(uint8_t c) = 0;

	virtual void printHeader() {}
};

// Prints an unsigned 8bit integer as Logisim format, for example "f f0"
class LogisimPrinter : public Printer {
	void print(uint8_t c);
	void printHeader();
};

// Prints an unsigned 8bit integer as hexadecimal, for example "0x0f 0xf0"
class HexPrinter : public Printer {
	void print(uint8_t c);
};

// Prints an unsigned 8bit integer as binary, for example "00001111 11110000"
class BinPrinter : public Printer {
	void print(uint8_t c);
};

// Prints an unsigned 8bit integer as raw character
class CharPrinter : public Printer {
	void print(uint8_t c);
};
