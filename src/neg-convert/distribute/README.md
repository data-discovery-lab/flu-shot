# negconvert
## Run Stanford NLP Server

Download Stanford CoreNLP at https://stanfordnlp.github.io/CoreNLP/index.html

The downloaded file at the moment is __*stanford-corenlp-full-2017-06-09.zip*__

Extract the zip file and navigate to the extracted location in Cmd (Windows) or Terminal (Mac and Unix).

Run this command to start the server:
```
$ java -mx4g -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer -port 9000 -timeout 15000
```
Verify if the server runs properly by browsing http://localhost:9000

For more information: https://stanfordnlp.github.io/CoreNLP/corenlp-server.html

## Install and use negconvert package on client

### Setup virtual environment (Optional)
Install virtualenv if not installed yet.
```
$ pip install virtualenv
```
Create a new environment named __venvpy36__
```
$ virtualenv --python=/path/to/python venvpy36
```
Activate venvpy36
```
# In Mac and Linux
$ source venvpy36/bin/activate
```
```
# In Windows
$ venvpy36\Scripts\activate
```
### Install and run the package
```
$ pip install negconvert
$ negconvert unalteredTweets.csv
```
### Deactivate the virtual environment
```
# In Mac and Linux
$ deactivate
```
```
# In Windows
$ venvpy36\Scripts\deactivate.bat
```
## Requirements and other information
### Input file
The input file has the following requirements:
- Is a comma delimited csv file
- The header includes these fields: user,text,date,state,takeFlushot,negativeFlushot
- The date format is yyyyMMdd (e.g. 20140109)
- takeFlushot and negativeFlushot are flags, which have the value of 0 or 1

### Output files
#### 1. _freq.csv
This file contains the frequency of the words in the text. This file is only used for word normalization.
#### 2. _converted.csv
This file contains the original text and the converted text.
