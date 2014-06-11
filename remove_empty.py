f = open('AMD Images.xml')
fout = open('images_out.xml', 'w')

for line in f:
    if(line.isspace() == False):
        fout.write(line )

f.close()
fout.close()
