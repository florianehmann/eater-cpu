"""
function assemble(source_lines):
    # ---------- PASS 1: parse + collect labels ----------
    pc ← 0
    symbols ← empty dictionary
    parsed ← empty list

    for each line in source_lines with line_number:
        line ← remove comments and trim whitespace
        if line is empty:
            continue

        if line contains a label (ends with ':'):
            label ← extract label
            symbols[label] ← pc
            line ← rest of line after label (may be empty)

        if line starts with ".org":
            pc ← parse number after .org
            record (type=".org", value=pc) in parsed
            continue

        if line starts with ".db":
            values ← list of numbers/labels after .db
            record (type=".db", values=values) in parsed
            pc ← pc + number of values
            continue

        else:  # must be instruction
            mnemonic, operand ← split(line)
            record (type="instr", mnemonic, operand) in parsed
            pc ← pc + 1   # (assuming 1 byte per instruction)

    # ---------- PASS 2: resolve + emit ----------
    pc ← 0
    memory ← array of zeros (size = memory size)

    for each entry in parsed:
        if entry.type == ".org":
            pc ← entry.value

        if entry.type == ".db":
            for val in entry.values:
                if val is number: byte ← val
                else if val is label: byte ← symbols[val]
                write byte into memory[pc]
                pc ← pc + 1

        if entry.type == "instr":
            opcode, operand_type ← lookup mnemonic in INSTR_SET
            if operand_type == "none":
                byte ← opcode << 4
            else:
                if operand is number: val ← parse number
                else: val ← symbols[operand]
                byte ← (opcode << 4) OR (val & 0x0F)
            write byte into memory[pc]
            pc ← pc + 1

    return memory
"""

"""
Support directives: .byte, .word, .org, .segment, .export, .import, .res
Optional extensions: .ascii, .asciiz, .include
"""

import re
from pathlib import Path


COMMENT = ';'

PATTERN_LABEL = re.compile(r"([a-zA-Z]+):")
PATTERN_DIRECTIVE = re.compile(r"[.]([a-zA-Z]+)")
PATTERN_INSTRUCTION = re.compile(r"([a-zA-Z]+)\s*([a-zA-Z]*)")


def clean_line(line: str) -> str:
    ret = line.split(COMMENT)[0]
    return ret.strip()


def pass_one(program: list[str]):
    pc = 0
    symbols = {}
    parsed = []

    for line_number, line in enumerate(program):
        line = clean_line(line)
        if line == '':
            continue

        print(f"{line_number:02d}: {line}")

        # process potential label
        match = PATTERN_LABEL.match(line)
        if match:
            label = match.group(1)
            symbols[label] = pc  # TODO handle the case that symbol already exists
            print(f'\tFound label: {label}')
            line = line.removeprefix(match.group(0)).strip()
            if line == '':
                continue
            print(f'\tContinuing to process line: {line}')
        
        # process potential directive
        match = PATTERN_DIRECTIVE.match(line)
        if match:
            directive = match.group(1)
            print(f'\tFound directive: {directive}')
            # TODO handle directive
        
        # process potential instruction
        match = PATTERN_INSTRUCTION.match(line)
        if match:
            opcode = match.group(1)
            operand = match.group(2)
            print(f"\tFound instruction: {opcode} {operand}")
            pc += 1
    
    print('\nPASS 1 complete')
    print(f"Found symbols {symbols}")


def assemble(program: list[str]):
    pass_one(program)


def main():
    source_file = Path.cwd() / 'programs/hello_world.s'
    with source_file.open() as f:
        program = f.readlines()
    assemble(program)


if __name__ == "__main__":
    main()
