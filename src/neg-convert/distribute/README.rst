###To setup a virtual environment:
$ pip install virtualenv
$ virtualenv --python=/path/to/python venvpy36

###To activate the virtual environment:
$ source venvpy36/bin/activate (for Linux)
$ venvpy36\Scripts\activate (for Windows)

###To install the package:
$ pip install negconvert

###To run the package:
$ negconvert unalteredTweets.csv

###To deactivate the virtual environment
$ venvpy36\Scripts\deactivate.bat (for Windows)
