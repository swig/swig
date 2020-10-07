import re

def makeBold(s):
	ret=s.group()
	print(ret)
	return "**"+ret+"**"

with open('Warnings.rst', 'r') as f:
	lines=f.readlines()

with open('Warnings.rst', 'w') as f:
	for line in lines:
		prev_line=line
		line=re.sub(r'[0-9]{3}\.', makeBold, line)
		if prev_line!=line:
			print(line)
		f.write(line)