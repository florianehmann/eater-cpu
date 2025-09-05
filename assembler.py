"""
Minimalist assembler for the Ben Eater CPU vaguely compatible with oldstyle syntax.

Support directives: .byte, .org, .segment
Planned directives: .word, .export, .import, .res
Optional extensions: .ascii, .asciiz, .include
"""

import argparse
import logging
import re
from dataclasses import dataclass
from enum import auto, Enum
from pathlib import Path

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.WARN)

COMMENT = ';'

PATTERN_LABEL = re.compile(r"([a-zA-Z]+):")
PATTERN_DIRECTIVE = re.compile(r"[.]([a-zA-Z]+)")
PATTERN_INSTRUCTION = re.compile(r"([a-zA-Z]+)\s*([a-zA-Z]*)")
PATTERN_NUMBER = re.compile(r"[0-9$]")


class DirectiveCode(Enum):
    """Directives recognized by the assembler."""
    ORG = auto()
    SEGMENT = auto()
    BYTE = auto()


class Opcode(Enum):
    """Operations and opcodes of the CPU's ISA."""
    NOP = 0x0
    LDA = 0x1
    ADD = 0x2
    SUB = 0x3
    STA = 0x4
    LDI = 0x5
    JMP = 0x6
    JC  = 0x7
    JZ  = 0x8
    OUT = 0xe
    HLT = 0xf

    def has_operand(self) -> bool:
        """Returns true of the operation takes an operand."""
        if self in [self.NOP, self.OUT, self.HLT]:
            return False
        return True


@dataclass
class Directive:
    """Parser record for a directive."""

    code: DirectiveCode
    """Which directive is parsed."""

    operand: str
    """Operand of the directive."""


@dataclass
class Instruction:
    """Parser record for an instruction."""

    opcode: Opcode
    """Operation of the instruction line."""

    operand: str
    """Operand of the instruction.
    
    May be an empty string for instructions that don't have operands.
    """


def clean_line(line: str) -> str:
    """Removes comments and whitespace from lines."""
    ret = line.split(COMMENT)[0]
    return ret.strip()


def is_numbers(string: str) -> bool:
    """Check if an operand string is a number or a list of numbers."""
    return PATTERN_NUMBER.match(string) is not None


def string_to_number(numberstring: str) -> int:
    """Convert an operand string representing a single number into an int."""
    if numberstring.startswith('$'):
        return int(numberstring[1:], base=16)
    
    return int(numberstring)


def string_to_numbers(numberstring: str) -> int:
    """Convert an operand string representing multiple numbers into ints."""
    parts = numberstring.split(',')
    numbers = []
    for part in parts:
        numbers.append(string_to_number(part.strip()))
    return numbers


def pass_one(program: list[str]) \
        -> tuple[dict[str, int], list[Directive | Instruction]]:
    """Perform first assembly pass.
    
    In this pass we collect directives and instructions and resolve the
    addresses of symbols.

    Returns the mapping of symbol name to memory address and the list of
    parsed directives and instructions.
    """

    pc = 0
    symbols = {}
    parsed = []

    for line_number, line in enumerate(program):
        line = clean_line(line)
        if line == '':
            continue

        logger.debug(f"{line_number:02d} {pc:02d}: {line}")

        # process potential label
        match = PATTERN_LABEL.match(line)
        if match:
            label = match.group(1)
            symbols[label] = pc
            logger.debug(f'\tFound label: {label}')
            line = line.removeprefix(match.group(0)).strip()
            if line == '':
                continue
            logger.debug(f'\tContinuing to process line: {line}')
        
        # process potential directive
        match = PATTERN_DIRECTIVE.match(line)
        if match:
            record = Directive(
                DirectiveCode[match.group(1).upper()],
                operand=line.removeprefix(match.group(0)).strip(),
            )
            logger.debug(f'\tFound directive: {record}')
            parsed.append(record)
            match record.code:
                case DirectiveCode.SEGMENT:
                    logger.info("Found segment directive. Ignoring.")
                case DirectiveCode.ORG:
                    pc = string_to_number(record.operand)
                case DirectiveCode.BYTE:
                    pc += len(string_to_numbers(record.operand))
        
        # process potential instruction
        match = PATTERN_INSTRUCTION.match(line)
        if match:
            record = Instruction(
                opcode=Opcode[match.group(1).upper()],
                operand=match.group(2),
            )
            logger.debug(f"\tFound instruction: {record}")
            parsed.append(record)
            pc += 1
    
    logger.info('PASS 1 complete')
    logger.info(f"Found symbols {symbols}")
    logger.info('Parsed records:')
    for record in parsed:
        logger.info(f"\t{record}")

    return symbols, parsed


def pass_two(symbols: dict[str, int], parsed: list[Directive | Instruction]) \
        -> list[int]:
    """Perform second assembly pass.
    
    In this pass we assemble the machine code from the parsed directives and
    instructions and symbol mappings from the first pass.

    Returns a list of byte values representing the memory image of the
    assembled program.
    """

    pc = 0
    memory = [0 for _ in range(16)]

    for record in parsed:
        if isinstance(record, Directive):
            match record.code:
                case DirectiveCode.ORG:
                    pc = string_to_number(record.operand)
                case DirectiveCode.BYTE:
                    if is_numbers(record.operand):
                        numbers = string_to_numbers(record.operand)
                        for number in numbers:
                            memory[pc] = number
                            pc += 1
                    else:
                        memory[pc] = symbols[record.operand]
                        pc += 1

        elif isinstance(record, Instruction):
            if record.opcode.has_operand():
                operand: int
                if is_numbers(record.operand):
                    operand = string_to_number(record.operand)
                else:
                    operand = symbols[record.operand]
                byte = record.opcode.value << 4 | operand
                memory[pc] = byte
            else:
                byte = record.opcode.value << 4
                memory[pc] = byte
            pc += 1

    return memory


def assemble(program: list[str]) -> list[int]:
    """Assemble source code and return machine code as list of byte values.
    
    `program` contains the source code as a list of lines.
    """
    symbols, parsed = pass_one(program)
    return pass_two(symbols, parsed)


def main() -> None:
    """Read arguments and assemble program."""

    parser = argparse.ArgumentParser(
        prog='python assembler.py',
        description=(
            'Assembler for the Ben Eater CPU. Warning: This assembler '
            'will fail silently or with terrible error messages on incorrect '
            'input.'
        ),
    )
    parser.add_argument('filename')
    parser.add_argument('-o', metavar='output_name', default='out.hex',
                        help='output filename')
    args = parser.parse_args()

    source_file = Path(args.filename).resolve()
    output_file = Path(args.o).resolve()
    with source_file.open() as f:
        program = f.readlines()
    memory = assemble(program)

    with output_file.open('w') as f:
        f.write(' '.join([f'{b:02x}' for b in memory]))


if __name__ == "__main__":
    main()
