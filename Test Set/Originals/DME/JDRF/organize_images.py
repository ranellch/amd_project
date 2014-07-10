import sys
import os
from pprint import pprint
import xml.etree.ElementTree as ET
from shutil import copy2, rmtree

def run_dir(basedir, subdir):
    dirname = basedir + '\\' + subdir
    output_dirname = dirname + '\\organized'
    print '[Folder]'
    try:
        rmtree(output_dirname)
        print '\tDeleted'
    except:
        print '\tDoesn\'t Exist'
        
    os.mkdir(output_dirname)       

    f = []
    for (dirpath, dirnames, filenames) in os.walk(dirname):
        f.append(filenames)
        
    xmlFile = 'none'
    for files in f:
        for file in files:
            fileName, fileExtension = os.path.splitext(file)
            if fileExtension == '.xml':
                if xmlFile == 'none':
                    xmlFile = file
                else:
                    print "[Error]\n\ttwo or more XML files exists"
                    return
    if xmlFile == 'none':
        print "[Error]\n\tCould find an XML file"
        return
                    
    print '[Error]'
    timing_list = dict()
    tree = ET.parse(dirname + '\\' + xmlFile)
    root = tree.getroot()
    for Image in root.iter('Image'):
        try:
            ID = Image.find('ID').text
            path = Image.find('ImageData').find('ExamURL').text
            
            end_index = path.rfind('\\')+1
            parsed_path = path[end_index:]
                        
            hour = float(Image.find('Injection').find('Time').find('Hour').text);
            min = float(Image.find('Injection').find('Time').find('Minute').text);
            sec = float(Image.find('Injection').find('Time').find('Second').text);
            final_time = sec + (min * 60.0) + (hour * 3600.0)
            if(os.path.isfile(dirname + '\\' + parsed_path)):
                timing_list[final_time] = [ID, parsed_path]
            else:
                print '\tCould not find file: ', ID, ' - ', parsed_path
        except:
            print '\tXML timing info could not be found: ', ID, ' - ', parsed_path

            
    root = ET.Element("video_seq")
    root.set('id', idrun);
    root.set('timing', subdir)

    the_list = (sorted(timing_list.items()))
    sort_id = 0
    for pairs in the_list:        
        time = str(pairs[0]).replace('.','_')
        id = pairs[1][0]
        path = dirname + '\\' + pairs[1][1]
        fileName, fileExtension = os.path.splitext(path)
        output_name = 'e' + str(sort_id) + '-t' + time + '-i' + id + fileExtension
        copy2(path, output_dirname + '\\' + output_name)
        
        frame = ET.SubElement(root, 'frame')
        frame.set('id', str(sort_id))
        frame.set('orig_id', str(id))
        frame.set('time', time.replace('_','.'))
        frame.set('path', output_name);
        
        sort_id += 1
 
    tree = ET.ElementTree(root);
    
    tree.write(output_dirname + '\\video.xml');
 
if len(sys.argv) != 2:
    print "must enter a directory name to align"
    
idrun = sys.argv[1]
f1 = []
print '=====', idrun, '====='
for dirname in os.listdir(idrun):
    print '-----', dirname, '-----'
    run_dir(idrun, dirname)