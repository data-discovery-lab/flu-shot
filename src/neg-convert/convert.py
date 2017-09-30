# Andrew Salopek
# Texas Tech University

import csv
import re
import enchant
from stanfordcorenlp import StanfordCoreNLP

nlp = StanfordCoreNLP('http://corenlp.run', port=80)


def contraction(inTweet):
    with open('contractions.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'\b(' + '|'.join(mydict.keys()) + r')\b')
        result = re.sub(pattern, lambda m: mydict.get(m.group(), m.group()), inTweet)
    return parser(result)


def affirm(inTweet):
    with open('opposites.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'not\s(' + '|'.join(mydict.keys()) + r'\s)')
        result = re.sub(pattern, lambda m: mydict.get(m.group(1)), inTweet)
    return synonym(result)


def synonym(inTweet):
    with open('synonyms.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'\b(' + '|'.join(mydict.keys()) + r')\b')
        result = re.sub(pattern, lambda m: mydict.get(m.group(), m.group()), inTweet)
    return result


def spellCheck(inTweet):
    newTweet = re.sub(r'!*\?*', '', inTweet)
    dict = enchant.Dict("en-US")
    outStr = []
    pattern = re.compile(r'^[(@|#]\w+')
    wordList = newTweet.split()
    for word in wordList:
        if not (pattern.match(word)):
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
        else:
            outStr.append(word)
    string = " ".join(outStr)
    return contraction(string)


def parser(inTweet):
    wordlist = inTweet.split();
    dep = nlp.dependency_parse(inTweet)
    result = [item for item in dep if item[0] == "neg"]
    if result:
        for item in result:
            # first = item[2] - 1
            # second = item[1] - 1
            # print(wordlist[first], wordlist[second])
            contr = affirm(inTweet)
            return synonym(contr)
    else:
        return inTweet


with open('unalteredTweets.csv') as tweetcsv:
    tweets = csv.DictReader(tweetcsv)
    with open('convertedTweets.csv', 'w') as convertcsv:
        headers = ["user", "tweet", "date", "state", "takeFlushot", "negativeFlushot"]
        csvwrite = csv.DictWriter(convertcsv, fieldnames=headers)
        csvwrite.writeheader()
        i = 0
        for row in tweets:
            tweet = spellCheck(row['tweet'].lower())
            # tweet=spellCheck(row)
            print(i, tweet)
            i += 1
            csvwrite.writerow({"user": row["user"], "tweet": tweet[0], "date": row["date"], "state": row["state"],
                               "takeFlushot": row["takeFlushot"], "negativeFlushot": row["negativeFlushot"]})
