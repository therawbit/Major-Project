#!/bin/bash

# Sections to disassemble
sections=".data .text .rsrc .rdata .bss .tls .idata .edata .reloc .BSS .CODE .Pav"

# Loop through all the .exe files in the current directory
for exe_file in *.exe; do
    # Create an assembly file for each .exe without the "_all_sections" portion
    assembly_file="${exe_file%.exe}_all_sections.asm"
    new_assembly_file="${exe_file%.exe}.asm"

    # Loop through all the specified sections and disassemble them
    for section in $sections; do
        text=$(objdump -j "$section" -D "${exe_file}" -M intel | awk '/Disassembly/ { found=1 } found' | tail -n +2);

        # Use sed to remove the colon and ellipsis
        text=$(echo "$text" | sed -e 's/://g' -e 's/\.\.\.//g')

        # Use awk to prefix each line with the current section name
        text=$(echo "$text" | awk -v section="$section" '{print section ":" $1, $2, $3, $4, $5, $6, $7, $8, $9}')

        echo "$text" | tail -n +3 >> ${new_assembly_file};

    done
done

