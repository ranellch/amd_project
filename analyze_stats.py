import sys

filename = sys.argv[1]
file = open(filename, "r+")
sums = []
labels = []
error_pats = []
numpos = []
for line in file:
	line = line.rstrip()
	line = line.split(', ')
	print(line)
	if line[0] == 'Img':
		for i in range(1,len(line)):
			numpos.append(0)
			sums.append(0)
			labels.append(line[i])
		continue
	elif len(line) != 1:
		data = line[1:]
		first_str = data[0]
		if first_str[0] == 'E':
			error_pats.append(line[0])
			if line[2].count('-1') == 0:
				error_pats.append('False Positive')
			else:
				error_pats.append('No Positive')
		elif first_str[0] == 'O':
			continue
		else:
			for i in range(0,len(data)):
				sums[i] += float(data[i])
				numpos[i] += 1
	
avgs = [sums[i]/numpos[i] for i in range(0,len(sums))]
file.write('\n')
for i in range(0,len(avgs)):
	file.write('Average ' + labels[i] + ': %.4f\n' % avgs[i])

file.write('\n')
file.write('Error cases: \n')
for i in range(0,len(error_pats),2):
	file.write(error_pats[i] + ': ' + error_pats[i+1] + '\n')
		