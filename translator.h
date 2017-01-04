/**
 * Translator class, utility class for generating branching offset and printing the translated instructions
 *
 * piernov <piernov@piernov.org>
 */

#include "printer.h"
#include <vector>
#include <unordered_map>
#include <memory>

class Translator {
private:
	// Configuration, for compatibility with original Thumb assembly
	// Big-endian or little-endian mode
	bool little_endian = false;

	// Count one more instruction before the branching instruction for the offset generation
	bool additional_branch_prefetch = false;

	// Instructions buffer
	std::vector<uint16_t> buffer;

	// Current instruction number
	int currentInstr = 0;


	// Declared labels
	std::unordered_map<std::string, int> labelAddresses;

	// Branch instructions with not-yet declared labels
	std::unordered_map<int, std::string> incompleteBranchAddresses;

	// Printer class to use for final printing of the machine code
	std::shared_ptr<Printer> printer;

public:
	// Set the printer from the constructor
	Translator(std::shared_ptr<Printer> printer) : printer(printer) {}

	// Declare a label
	void addLabel(std::string label);

	// Generate an branching instruction offset for the given label relative to the current position
	uint8_t generateOffset(std::string label);

	// Add the missing branching instruction offset for post-declared labels
	int fillBranchOffsets();

	// Add an instruction to the buffer
	void addInstruction(uint16_t op);

	// Print all the instructions from the buffer using the printer class
	void printAll();
};
