/**
 * Translator class, utility class for generating branching offset and printing the translated instructions
 *
 * piernov <piernov@piernov.org>
 */

#include "translator.h"
#include <iostream>

void Translator::addLabel(std::string label) {
	labelAddresses.insert({label, currentInstr}); // Add the label with the current instruction address
}

uint8_t Translator::generateOffset(std::string label) {
	if (labelAddresses.find(label) != labelAddresses.end()) { // Label already declared
		auto offset = labelAddresses[label] - currentInstr; // Calculate the offset

		if (additional_branch_prefetch)
			offset -= 2; // Take into account the prefetch operation

		if (offset < -128 || offset > 127) { // Offset overflow, larger than an IMM8
			std::cerr << "Offset " << offset << " out of bounds for label " << label << std::endl;
			return 0;
		}

		int8_t offset8 = offset; // Fix width to 8-bit, signed (offset can be negative)
		return offset8;
	}

	incompleteBranchAddresses.insert({currentInstr, label}); // Label not declared, add the branch instruction for later filling
	return 0;
}

int Translator::fillBranchOffsets() {
	for (auto &address : incompleteBranchAddresses) { // Loop through the branch instructions without offsets
		currentInstr = address.first; // generateOffset expect the currentInstr to be the address of the branch instruction
		auto offset = generateOffset(address.second);

		if (!offset) { // Offset not calculated or equal to 0, ie. label not found or invalid (pointing to this instruction)
			std::cerr << "Invalid label " << address.second
				<< " for branching instruction at offset " << address.first
				<< std::endl;
		} else {
			auto op = buffer.at(address.first);
			buffer.at(address.first) = op + offset; // Add the offset to the branching instruction
		}
	}
}

void Translator::addInstruction(uint16_t op) {
	buffer.push_back(op);
	currentInstr++;
}

void Translator::printAll() {
	std::cout << "v2.0 raw" << std::endl;
	for (auto &op : buffer) {
		if (little_endian) { // Reverse printing for little-endian mode
			printer->print(op & 0xFF);
			printer->print(op >> 8);
		} else {
			printer->print(op >> 8); // Extract most significant byte
			printer->print(op & 0xFF); // Extract least significant byte
		}
	}
}
