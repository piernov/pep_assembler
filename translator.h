#include <iostream>
#include <bitset>
#include <vector>
#include <unordered_map>
#include <fstream>

class Translator {
private:
	// Configuration
	bool little_endian = true;
	bool additional_branch_prefetch = true;

	std::vector<uint16_t> buffer;
	std::unordered_map<std::string, int> labelAddresses;
	int currentInstr = 0;
	std::unordered_map<int, std::string> incompleteBranchAddresses;

	static void printHex(uint8_t num) {
		std::cout << "0x" << std::hex << std::setfill('0') << std::setw(2) << num << " ";
	}

	static void printBin(uint8_t num) {
		std::bitset<8> bs(num);
		std::cout << bs << " ";
	}

	static void printChar(uint8_t c) {
		std::cout << (unsigned char) c;
	}

	static constexpr auto printer = &printBin;
public:
	void addLabel(std::string label) {
		labelAddresses.insert({label, currentInstr});
	}

	uint8_t generateOffset(std::string label) {
		if (labelAddresses.find(label) != labelAddresses.end()) {
			auto offset = labelAddresses[label];
			offset -= currentInstr;
			if (additional_branch_prefetch)
				offset -= 2; // Take into account the prefetch operation

			std::cout << "Calculated offset: " << offset << std::endl;

			if (offset < -128 || offset > 127) {
				std::cerr << "Offset " << offset << " out of bounds for label " << label << std::endl;
				return 0;
			}

			int8_t offset8 = offset;
			return offset8;
		}
		incompleteBranchAddresses.insert({currentInstr, label});
		return 0;
	}

	int fillBranchOffsets() {
		for (auto &address : incompleteBranchAddresses) {
			currentInstr = address.first; // generateOffset expect the previous instruction address
			auto offset = generateOffset(address.second);
			if (!offset) {
				std::cerr << "Invalid label " << address.second
					<< " for branching instruction at offset " << address.first
					<< std::endl;
			} else {
				uint8_t op = buffer.at(address.first);
				std::cout << "Address: " << address.first << std::endl;
				std::cout << "Original instr: ";
				printer(op >> 8);
				printer(op & 0xFF);
				buffer.at(address.first) = op + offset;
				std::cout << std::endl;
				std::cout << "New instr: ";
				op = buffer.at(address.first);
				printer(op >> 8);
				printer(op & 0xFF);
				std::cout << std::endl;
			}
		}
	}

	void printInstruction(uint16_t op) {
		buffer.push_back(op);
		printer(op >> 8);
		printer(op & 0xFF);
		std::cout << std::endl;
		currentInstr++;
	}

	void printAll() {
		std::vector<char> vec;
		for (auto &op : buffer) {
			printer(op >> 8);
			printer(op & 0xFF);

			if (little_endian) {
				vec.push_back(op & 0xFF);
				vec.push_back(op >> 8);
			} else {
				vec.push_back(op >> 8);
				vec.push_back(op & 0xFF);
			}
		}

		std::ofstream outfile("output.bin", std::ios::out | std::ios::binary);
		outfile.write(vec.data(), vec.size());
	}
};
