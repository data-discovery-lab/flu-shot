# Andrew Salopek
# Texas Tech University

import csv
import re
import enchant


def contraction(inTweet: str, contr, spell, aff, syn) -> str:
    with open('contractions.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'\b(' + '|'.join(mydict.keys()) + r')\b')
        result = re.subn(pattern, lambda m: mydict.get(m.group(), m.group()), inTweet)
        if (result[1] > 0):
            contr = True
        else:
            contr = False
    return spellCheck(result[0], contr, spell, aff, syn)


def affirm(inTweet: str, contr, spell, aff, syn) -> str:
    with open('opposites.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'not\s(' + '|'.join(mydict.keys()) + r'\b)')
        result = re.subn(pattern, lambda m: mydict.get(m.group(1)), inTweet)
        if (result[1] > 0):
            aff = True
        else:
            aff = False
    return synonym(result[0], contr, spell, aff, syn)


def synonym(inTweet: str, contr, spell, aff, syn) -> str:
    with open('synonyms.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'\b(' + '|'.join(mydict.keys()) + r')\b')
        result = re.subn(pattern, lambda m: mydict.get(m.group(), m.group()), inTweet)
        if (result[1] > 0):
            syn = True
        else:
            syn = False
    return (result[0], contr, spell, aff, syn)


def spellCheck(inTweet, contr, spell, aff, syn):
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
                    spell = True
                except:
                    outStr.append(word)
            else:
                outStr.append(word)
        except ValueError:
            pass
    string = " ".join(outStr)
    return affirm(string, contr, spell, aff, syn)


with open('unalteredTweets.csv') as tweetcsv:
    tweets = csv.DictReader(tweetcsv)
    with open('convertedTweets.csv', 'w') as convertcsv:
        headers = ["user", "tweet", "date", "state", "takeFlushot", "negativeFlushot"]
        # headers = ['tweet']
        csvwrite = csv.DictWriter(convertcsv, fieldnames=headers)
        csvwrite.writeheader()
        i = 0
        for row in tweets:
            contr = False
            spell = False
            aff = False
            syn = False
            tweet = contraction(row['tweet'].lower(), contr, spell, aff, syn)
            print(i, tweet)
            i += 1
            csvwrite.writerow({"user": row["user"], "tweet": tweet[0], "date": row["date"], "state": row["state"],
                               "takeFlushot": row["takeFlushot"], "negativeFlushot": row["negativeFlushot"]})
