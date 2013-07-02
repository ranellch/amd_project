import sys

input_file = sys.argv[1]
output_file = sys.argv[2]

f = open(input_file)

longstring = '';

for line in f:
    if(line.isspace() == False):
        longstring += line

f.close()

fout = open(output_file, 'w')
fout.write(longstring)
fout.close()
