import sys
import csv
import re


def freqSort(text):
    frequency = {}
    if (text):
        for row in text:
            match_pattern = re.findall(r'\b[a-z]{3,15}\b', row['text'].lower())
            for word in match_pattern:
                count = frequency.get(word, 0)
                frequency[word] = count + 1
    with open(sys.argv[1] + '_freq.csv', 'w') as csv_file:
        writer = csv.writer(csv_file)
        for key, value in frequency.items():
            writer.writerow([key, value])


print(sys.argv[1])
with open(sys.argv[1], encoding="utf8") as textcsv:
    text = csv.DictReader(textcsv)
    freqSort(text)
