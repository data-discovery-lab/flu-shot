# Andrew Salopek
# Texas Tech University

import csv
import re
import enchant
import operator
from stanfordcorenlp import StanfordCoreNLP

nlp = StanfordCoreNLP('http://corenlp.run', port=80)


def contraction(inTweet, sorted_d):
    with open('contractions.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'\b(' + '|'.join(mydict.keys()) + r')\b')
        result = re.sub(pattern, lambda m: mydict.get(m.group(), m.group()), inTweet)
    return parser(result, sorted_d)


def affirm(inTweet, sorted_d):
    with open('opposites.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        pattern = re.compile(r'not\s(' + '|'.join(mydict.keys()) + r'\s)')
        result = re.sub(pattern, lambda m: mydict.get(m.group(1)), inTweet)
    return synonym(result, sorted_d)


def synonym(inTweet, sorted_d):
    wordList = inTweet.split()
    synArray = []
    with open('synonyms.csv') as f:
        f.readline()  # ignore first line (header)
        mydict = dict(csv.reader(f, delimiter=','))
        for word in wordList:
            if word in mydict.values():
                synArray.append(word)
                while (word):
                    try:
                        word = mydict[word]
                        # synArray.append(word)
                        if word in mydict.keys():
                            synArray.append(word)
                        else:
                            synArray.append(word)
                    except:
                        break
            if (synArray):
                maxCnt = 0
                maxWord = synArray[0]
                for element in synArray:
                    if dict(sorted_d)[element]:
                        if (dict(sorted_d)[element] > maxCnt):
                            maxCnt = dict(sorted_d)[element]
                            maxWord = element
                else:
                    pass
                wordList = [w.replace(word,maxWord) for w in wordList]
                word = maxWord
        print("62",wordList)

                    #
                    #
                    #
                    # else:
                    #     print("false")
                    # pattern = re.compile(r'\b(' + '|'.join(mydict.keys()) + r')\b')
                    # result = re.sub(pattern, lambda m: mydict.get(m.group(), m.group()), inTweet)
                    # return result


def spellCheck(inTweet,sorted_d):
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
    return contraction(string, sorted_d)


def parser(inTweet, sorted_d):
    # wordlist = inTweet.split()
    dep = nlp.dependency_parse(inTweet)
    result = [item for item in dep if item[0] == "neg"]
    if result:
        for item in result:
            # first = item[2] - 1
            # second = item[1] - 1
            # print(wordlist[first], wordlist[second])
            contr = affirm(inTweet, sorted_d)
            return synonym(contr, sorted_d)
    else:
        return synonym(inTweet, sorted_d)


def sort(tweets):
    if (tweets):
        for row in tweets:
            match_pattern = re.findall(r'\b[a-z]{3,15}\b', row['tweet'].lower())
            for word in match_pattern:
                count = frequency.get(word, 0)
                frequency[word] = count + 1
            frequency_list = frequency.keys()
            sorted_d = sorted(frequency.items(), key=operator.itemgetter(1), reverse=True)
        return sorted_d


with open('unalteredTweets.csv') as tweetcsv:
    tweets = csv.DictReader(tweetcsv)
    frequency = {}
    sorted_d = sort(tweets)
    with open('convertedTweets.csv', 'w') as convertcsv:
        headers = ["user", "tweet", "date", "state", "takeFlushot", "negativeFlushot"]
        csvwrite = csv.DictWriter(convertcsv, fieldnames=headers)
        csvwrite.writeheader()
        i = 0
        for row in tweets:
            tweet = spellCheck(row['tweet'].lower(), sorted_d)
            print(i, tweet)
            i += 1
            csvwrite.writerow({"user": row["user"], "tweet": tweet[0], "date": row["date"], "state": row["state"],
                               "takeFlushot": row["takeFlushot"], "negativeFlushot": row["negativeFlushot"]})
