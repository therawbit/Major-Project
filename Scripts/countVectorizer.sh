#!/bin/bash

# Create a header for the CSV file if it doesn't exist
if [ ! -f result.csv ]; then
  echo "ID,.text:,.Pav:,.idata:,.data:,.bss:,.rdata:,.edata:,.rsrc:,.tls:,.reloc:,.BSS:,.CODE,jmp,mov,retf,push,pop,xor,retn,nop,sub,inc,dec,add,imul,xchg,or,shr,cmp,call,shl,ror,rol,jnb,jz,rtn,lea,movzx,edx,esi,eax,ebx,ecx,edi,ebp,esp,eip" > result.csv
fi

# Define an array of field names
fields=("ID" ".text:" ".Pav:" ".idata:" ".data:" ".bss:" ".rdata:" ".edata:" ".rsrc:" ".tls:" ".reloc:" ".BSS:" ".CODE" "jmp" "mov" "retf" "push" "pop" "xor" "retn" "nop" "sub" "inc" "dec" "add" "imul" "xchg" "or" "shr" "cmp" "call" "shl" "ror" "rol" "jnb" "jz" "rtn" "lea" "movzx" "edx" "esi" "eax" "ebx" "ecx" "edi" "ebp" "esp" "eip")

# Create or initialize the parsed files list
parsed_files_file="parsed_files.txt"
touch "$parsed_files_file"

# Iterate through all text files in the current directory
for file in *.asm; do
  # Check if the file has been parsed already
  if grep -Fxq "$file" "$parsed_files_file"; then
    echo "Skipping $file (already parsed)"
  else
    # Process the file
    echo -n "$file," >> result.csv
    for field in "${fields[@]}"; do
      echo -n "$(cat "$file" | grep "$field" | wc -l)," >> result.csv
    done
    echo "" >> result.csv

    # Add the filename to the list of parsed files
    echo "$file" >> "$parsed_files_file"
  fi
done
