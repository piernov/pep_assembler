#include "printer.h"
#include <vector>
#include <unordered_map>
#include <memory>

class Translator {
private:
	// Configuration
	bool little_endian = false;
	bool additional_branch_prefetch = false;

	std::vector<uint16_t> buffer;
	std::unordered_map<std::string, int> labelAddresses;
	int currentInstr = 0;
	std::unordered_map<int, std::string> incompleteBranchAddresses;

	std::shared_ptr<Printer> printer;

public:
	Translator(std::shared_ptr<Printer> printer) : printer(printer) {}

	void addLabel(std::string label);

	uint8_t generateOffset(std::string label);

	int fillBranchOffsets();

	void addInstruction(uint16_t op);

	void printAll();
};
