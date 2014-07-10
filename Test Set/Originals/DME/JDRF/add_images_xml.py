import sys
import os

def run_dir(basedir, rundir):
    dirname = basedir + '\\' + rundir + '\\organized'
    try:
        os.stat(dirname)
    except:
        return;

    for file in os.listdir(dirname):
        fileName, fileExtension = os.path.splitext(file)
        
        underscores = []
        index = 0
        for char in fileName:
            if char == '-': underscores.append(index)
            index += 1
        
        newide = fileName.find('e') + 1
        id = fileName[newide:newide + (underscores[0] - newide)]
        
        newidt = fileName.find('t') + 1
        time = fileName[newidt:newidt + (underscores[1] - newidt)].replace('_','.')
        
        
        
idrun = sys.argv[1]
f1 = []
print '=====', idrun, '====='
for dirname in os.listdir(idrun):
    print '-----', dirname, '-----'
    run_dir(idrun, dirname)