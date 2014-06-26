import sys

filename = sys.argv[1]
file = open(filename, "a+")
for line in file:
    print(line[0:3]) 
