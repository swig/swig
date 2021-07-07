import re
import glob

number_regex = re.compile(r'^\d[\.\d]+ ', flags=re.M)
for f in glob.glob('source/Manual/*.rst'):
    text = open(f).read()
    text = number_regex.sub('', text)
    open(f, 'w').write(text)