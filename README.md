## pass generate-phrase

a passphrase generator for pass


## installation

basically, as described here: https://www.passwordstore.org/#extensions

##### for a user installation that should be 

    wget https://raw.githubusercontent.com/puhoy/pass-generate-phrase/master/generate-phrase/generate-phrase.bash -P ~/.password-store/.extensions/
    wget https://raw.githubusercontent.com/puhoy/pass-generate-phrase/master/generate-phrase/eff_large_wordlist.txt -P ~/.password-store/.extensions/

    # and make the script executable
    chmod +x ~/.password-store/.extensions/generate-phrase.bash

and set `PASSWORD_STORE_ENABLE_EXTENSIONS` environment variable to true


##### and for a system wide installation

put `generate-phrase.bash` and `eff_large_wordlist.txt` in `/usr/lib/password-store/extensions` (or whatever that is for your distribution)

and make the script executable:

`/usr/lib/password-store/extensions/generate-phrase.bash`

(no need to set the environment var)


## usage

    pass generate-phrase
        [--wordcount,-w wordcount] 
        [--wordlist,-l wordlist]
        [--separator,-s separator] 
        [--randomupper,-u] 
        [--clip,-c]
        [--qrcode,-q]
        [--in-place,-i | --force,-f]
        pass-name

        generate a passphrase with WORDCOUNT (or 4) words,
        made from words in WORDLIST* (or the EFFs long wordlist**),
        separated by SEPARATOR (or "-")

        * a diceware list, each line like "11111 banana"
        **https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases


#### options

`--wordcount, -w N`

generate N words (default 4)

`--wordlist, -l /path/to/list`

use file under /path/to/list instead of included wordlist 

(default the [EFFs long wordlist](https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases)) 

`--separator, -s SEPARATOR` 

use SEPARATOR to separate the words (default "-")

`--randomupper,-u`

randomly uppercase words


...for example

    $ pass generate-phrase my/new/testpassword
    mkdir: created directory '/home/USER/.password-store/my'
    mkdir: created directory '/home/USER/.password-store/my/new'
    [master 045a5d5] Add generated password for my/new/testpassword.
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 my/new/testpassword.gpg
    The generated password for my/new/testpassword is:
    filing-choice-gecko-campus

    
    $ pass generate-phrase my/new/testpassword --separator="+" --wordcount 8 --wordlist diceware_german.txt --randomupper
    An entry already exists for my/new/testpassword. Overwrite it? [y/N] y
    [master 15b7123] Add generated password for my/new/testpassword.
     1 file changed, 0 insertions(+), 0 deletions(-)
     rewrite my/new/testpassword.gpg (100%)
    The generated password for my/new/testpassword is:
    oben+UO+GEPARD+wq+HUEPFTE+WONNE+zitrat+TOD

    

### the wordlist

its the EFFs "long wordlist" from here:

https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases

