# Andrew Salopek
# Texas Tech University

import csv
import re
import enchant


def contraction(inTweet: str) -> str:
    with open('contractions.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'\b(' + '|'.join(mydict.keys()) + r')\b')
        result = re.sub(pattern, lambda m: mydict.get(m.group(), m.group()), inTweet)
    return spellCheck(result)


def affirm(inTweet: str) -> str:
    with open('opposites.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'not\s(' + '|'.join(mydict.keys()) + r'\b)')
        result = re.sub(pattern, lambda m: mydict.get(m.group(1)), inTweet)
    return synonym(result)


def synonym(inTweet: str) -> str:
    with open('synonyms.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'\b(' + '|'.join(mydict.keys()) + r')\b')
        result = re.sub(pattern, lambda m: mydict.get(m.group(), m.group()), inTweet)
    return result


def spellCheck(inTweet):
    dict = enchant.Dict("en-US")
    outStr = []
    wordList = inTweet.split()
    for word in wordList:
        word = re.sub('\!*\?*\.*\,*#*', '', word)
        try:
            if not (dict.check(word)):
                try:
                    newWord = dict.suggest(word)
                    outStr.append(newWord[0])
                except:
                    outStr.append(word)
            else:
                outStr.append(word)
        except ValueError:
            pass
    string = " ".join(outStr)
    return affirm(string)


with open('unalteredTweets.csv') as tweetcsv:
    tweets = csv.DictReader(tweetcsv)
    with open('convertedTweets.csv', 'w') as convertcsv:
        headers = ["user", "tweet", "date", "state", "takeFlushot", "negativeFlushot"]
        csvwrite = csv.DictWriter(convertcsv, fieldnames=headers)
        csvwrite.writeheader()
        i = 0
        spellCheck("")
        for row in tweets:
            tweet = contraction(row['tweet'].lower())
            print(i, tweet)
            csvwrite.writerow({"user": row["user"], "tweet": tweet, "state": row["state"],
                               "takeFlushot": row["takeFlushot"], "negativeFlushot": row["negativeFlushot"]})
