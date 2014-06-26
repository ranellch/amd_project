import sys

filename = sys.argv[1]
file = open(filename, "r+")
sum_sens = 0
sum_spec = 0
sum_acc = 0
sum_prec = 0
sum_prob = 0
numpos = 0
error_pats = []
for line in file:
	line = line.split(', ')
	print(line)
	if line[0] == 'Img':
		continue
	elif len(line) != 1:
		data = line[1]
		if data[0] == 'E':
			error_pats.append(line[0])
			if line[2].count('-1') == 0:
				error_pats.append('False Positive')
			else:
				error_pats.append('No Positive')
		elif data[0] == 'O':
			continue
		else:
			numpos += 1
			sum_sens += float(data)
			sum_spec += float(line[2])
			sum_acc += float(line[3])
			sum_prec += float(line[4])
			sum_prob += float(line[5])
avg_sens = sum_sens/numpos
avg_spec = sum_spec/numpos
avg_acc = sum_acc/numpos
avg_prec = sum_prec/numpos
avg_prob = sum_prob/numpos

file.write('\nAverage Sensitivity: %.2f\n' % avg_sens)
file.write('Average Specificity: %.2f\n' % avg_spec)
file.write('Average Accuracy: %.2f\n' % avg_acc)
file.write('Average Precision: %.2f\n' % avg_prec)
file.write('Average Probability: %.2f\n\n' % avg_prob)
file.write('Error cases: \n')
for i in range(0,len(error_pats)/2):
	file.write(error_pats[i] + ': ' + error_pats[i+1] + '\n')
		