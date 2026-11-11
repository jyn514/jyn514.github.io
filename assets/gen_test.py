from random import randint

million = 10**5

with open('/usr/share/dict/words') as word_file:
    words = word_file.readlines()

for i in range(million):
    offset = randint(0, million / 2)
    diff = randint(0, million / 4)
    print(randint(offset, offset + diff),
          randint(offset + diff, offset + offset + diff*2),
          words[randint(0, len(words) - 1)], end='')
