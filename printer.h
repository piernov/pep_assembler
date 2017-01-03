#include <cstdint>

class Printer {
public:
	virtual void print(uint8_t c) = 0;
};

class HexPrinter : public Printer {
	void print(uint8_t c);
};

class BinPrinter : public Printer {
	void print(uint8_t c);
};

class CharPrinter : public Printer {
	void print(uint8_t c);
};
