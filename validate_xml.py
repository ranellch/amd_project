import pprint
import xml.etree.ElementTree as ET
original_file = 'AMD Images.xml'
output_file = 'temp.xml'
tree = ET.parse(original_file)
root = tree.getroot()

id = dict()

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
        if time not in id[inid]:
            id[inid][time] = dict()
	    id[inid][time][eye] = dict()
	    id[inid][time][eye][1] = child
	else:
            if eye not in id[inid][time]:
                id[inid][time][eye] = dict()
		id[inid][time][eye][1] = child
            else:
                maxkey = 0
                for key in id[inid][time][eye]:
                    if(int(key) > maxkey):
                        maxkey = int(key)
                maxkey = maxkey + 1
                id[inid][time][eye][maxkey] = child

   
for keyid in id:
    print keyid
    for keytime in id[keyid]:
        for keyeye in id[keyid][keytime]:
            if(len(id[keyid][keytime][keyeye]) == 2):
                imagetag1 = id[keyid][keytime][keyeye][1]
                imagetag2 = id[keyid][keytime][keyeye][2]
                if len(imagetag1) == len(imagetag2):
                    root.remove(imagetag2)
                else:
                    if len(imagetag1) > len(imagetag2):
                        root.remove(imagetag1)
                    else:
                        root.remove(imagetag1)
                print keytime, " - ", keyeye, ": Removed One" 
	    elif(len(id[keyid][keytime][keyeye]) > 2):
                print keytime, " - ", keyeye, ": Has three copies"

tree.write(output_file)
