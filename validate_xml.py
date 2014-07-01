import sys
import pprint
import xml.etree.ElementTree as ET

write_output = 0
if len(sys.argv) != 2:
    print "You must enter either 'true' or 'false' for writing to output the cleaned file!"
    sys.exit(1)
else:
    if sys.argv[1] == 'true':
        write_output = 0
    elif sys.argv[1] == 'false':
        write_output = 1
    else:
        print "You must enter either 'true' or 'false' for writing to output the cleaned file!"
	sys.exit(1)

#File constants
original_file = 'AMD Images.xml'
output_file = 'temp.xml'

#Parse the input XML using ET object
tree = ET.parse(original_file)
root = tree.getroot()

#Declare the map for keeping track of elements
id = dict()

#Iterate on each image tag in the images root tag
for child in root:
    inid = child.attrib['id']
    time = child.attrib['time']
    eye = child.attrib['eye']

    if inid not in id:
        id[inid] = dict()
        id[inid][time] = dict()
        id[inid][time][eye] = dict()
        id[inid][time][eye][1] = child
    else:
        if eye not in id[inid]:
            id[inid][eye] = dict()
	    id[inid][eye][time] = dict()
	    id[inid][eye][time][1] = child
        else:
            if time not in id[inid][eye]:
                id[inid][eye][time] = dict()
                id[inid][eye][time][1] = child
            else:
                maxkey = 0
                for key in id[inid][eye][time]:
                    if(int(key) > maxkey):
                        maxkey = int(key)
                maxkey = maxkey + 1
                id[inid][eye][time][maxkey] = child


#Sort all of the ID's in the XML file
sorted_list = []
for uskey in id:
    sorted_list.append(uskey)
sorted_list.sort()


#Iterate on each id in the parsed XML file
total_count = 0
for keyid in sorted_list:
    print keyid
    for keyeye in id[keyid]:
        total_count = total_count + len(id[keyid][keyeye])
        for keytime in id[keyid][keyeye]:
            if(len(id[keyid][keyeye][keytime]) == 2):
                imagetag1 = id[keyid][keyeye][keytime][1]
                imagetag2 = id[keyid][keyeye][keytime][2]
                if len(imagetag1) == len(imagetag2):
                    root.remove(imagetag2)
                else:
                    if len(imagetag1) > len(imagetag2):
                        root.remove(imagetag1)
                    else:
                        root.remove(imagetag1)
                print "\t", keyeye, " - ", keytime, ": Has two copies...So I Removed One" 
	    elif(len(id[keyid][keyeye][keytime]) > 2):
                print "\t", keyeye, " - ", keytime, ": Has three copies...I do not know what to do"
print "Total Image Count: ", str(total_count)

if write_output == 1:
    tree.write(output_file)
