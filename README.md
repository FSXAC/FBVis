# FBVis
A facebook message archive visualizer inspired by gource

![screenshot image](doc/screenshot.png)

You are in the middle. Everyone that you've ever talked to on Facebook surrounds you. 
You will zap/get zapped, these zap represents the messages being exchanged between you and your friend. 
If the color of the zap is green, that means you sent the message. 
If the color is pink, that means you received the message.
The thickness of the zap is proportional to the character length of the message sent.

## Usage

### Pre-req

First you need to have a copy of your Facebook archive. 

You can do this by going into your Facebook settings -> download all data. 
Facebook will take a few hours to process your requets and let your know when it's available to download.

Unzip the files somewhere

### fbcap

Use the python tool [fbchat-archive-parser](https://github.com/ownaginatious/fbchat-archive-parser) to parse the HTML messages.
Do this by going into `html` folder and run

```shell
fbcap ./messages.htm -f csv > messages.csv
```

### More parse and sort

Now copy the output `messages.csv` into this repository's root directory.

Then open `parsechat.py` and edit the line containing `MASTER_NAME` and `MASTER_ALIAS` to be using your exact Facebook name. 
(TODO: this should be done either automatically, or be a parameter).

Now run the python file, a `sorted.csv` should be outputted.

### Processing

In processing, run `FBVis.pde`.
(TODO: make executable).
