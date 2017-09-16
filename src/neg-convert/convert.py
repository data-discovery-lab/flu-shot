# Andrew Dylan Salopek
# 9/6/2017
# Texas Tech Univeristy

# import csv module for r/w
import csv


# checks tweet for synonyms provided in a CSV table and
# replaces synonyms with the more common word
def synonym(inTweet: str) -> str:
    splitTweet = inTweet.split()
    convertedString = inTweet
    with open('synonyms.csv') as syncsv:
        dictionary = csv.DictReader(syncsv)
        for entry in dictionary:
            for word in splitTweet:
                if entry['previous'] == word:
                    wordIndex = splitTweet.index(entry['previous'])
                    splitTweet[wordIndex] = entry['synonym']
                    convertedString = " ".join(splitTweet)
        return convertedString


# checks tweet for negative phrase, eg "not fun"
# and replaces it with affirmative synonym, eg "unpleasant"
def affirm(inTweet: str) -> str:
    with open('opposites.csv') as dictcsv:
        dictionary = csv.DictReader(dictcsv)
        i = 0
        for entry in dictionary:
            wordlist = inTweet.split()
            if "not" in wordlist:
                try:
                    next = wordlist[wordlist.index("not") + 1]
                    if next == entry['previous']:
                        phrase = "not " + next
                        convertedString = inTweet.replace(phrase, entry['opposite'])
                        return synonym(convertedString)
                except IndexError:
                    print("Error")
                    return synonym(inTweet)
        return synonym(inTweet)


def contraction(inTweet: str) -> str:
    splitTweet = inTweet.split()
    convertedString = inTweet
    with open('contractions.csv') as contcsv:
        dictionary = csv.DictReader(contcsv)
        for entry in dictionary:
            for word in splitTweet:
                if entry['contraction'] == word:
                    wordIndex = splitTweet.index(entry['contraction'])
                    splitTweet[wordIndex] = entry['separate']
                    convertedString = " ".join(splitTweet)
        return affirm(convertedString)


# creates new tweet data set with altered text
with open('unalteredTweets.csv') as tweetcsv:
    tweets = csv.DictReader(tweetcsv)
    with open('convertedTweets.csv', 'w') as convertcsv:
        headers = ["user", "tweet", "date", "state", "takeFlushot", "negativeFlushot"]
        csvwrite = csv.DictWriter(convertcsv, fieldnames=headers)
        csvwrite.writeheader()
        i = 0
        for row in tweets:
            tweet = contraction(row['tweet'].lower())
            print(i, tweet)
            i += 1
            csvwrite.writerow({"user": row["user"], "tweet": tweet, "state": row["state"],
                               "takeFlushot": row["takeFlushot"], "negativeFlushot": row["negativeFlushot"]})
