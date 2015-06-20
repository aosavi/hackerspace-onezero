
# Practical Encryption #
## An introductory workshop for the not-so-paranoid ##

### Disclaimer ###
* Be cautious
    - No magics bullets exist
    - Don't buy into [snake oil][3]
        + "military-grade encryption"
        + "mathematical proof" (Popper)
    - Devil is in the details 
* Adapt to your needs/level of paranoia
    - Who is the attacker? What is the scenario?
        + Guarding state secrets from NSA
        + Hiding porn collection from girlfriend
        + Keeping private information from eavesdroppers / bulk collection programs
        + Storing your backups in the cloud
        + ...
* Security is all about trust
    - in yourself
    - in the people you work with
    - in the software you work with
    - in the computer you work on
    - in the network you use
    - ...
* Offence is easy, defence is hard
    - how to know you've been hacked? (Popper again)
* Main weakness: operational security (user)
    - weak passwords
    - outdated software
    - ...

### Preparation ###
Install GnuPG, using the [instructions](#gnu-privacy-guard) below. Get the hardened configuration file from our GitHub repository. Find the standard configuration file (gpg.conf), rename it gpg_old.conf and place the new configuration file in place of the old one.

### Cryptography ###
* It's everywhere
    - web traffic: HTTPS
    - wireless traffic: GSM, Bluetooth
    - disk encryption: TrueCrypt
    - ...
* Here: focus on e-mail communication
    - Bob sends a message to Alice
* Main problems:
    - Confidentiality (making sure only Alice can read the message)
        + Encryption
        + Decryption
    - Integrity (verifying that the message was really sent by Bob)
        + Making signatures
        + Signature verification

### Encryption ###

#### Symmetric encryption ####
![Symmetric encryption](https://upload.wikimedia.org/wikipedia/commons/2/27/Symmetric_key_encryption.svg)
* One shared key
    - Encryption
    - Decryption
    - Easy to compute ciphertext from plaintext and key
    - Really hard to compute plaintext (or key) from ciphertext
        + Ideally: as hard as brute-forcing (guessing)
* What are problems with this setup?
* Famous example: [Enigma][5] (1923)
![Enigma machine](https://upload.wikimedia.org/wikipedia/commons/c/c3/Enigma-Machine.jpg)
How was Enigma broken back in the days?
* Modern example: [AES-256][6] (2001)
* Problem: how to send the secret key?

##### Example 1 - Symmetric encryption #####
First, either download 'example1.txt' from the [repository](../pgp-workshop/example1.txt), or create your own example1.txt with some arbitrary message. This will be the plaintext message we want to encrypt. Now, while in the same directory as our plaintext message, we encrypt using symmetric encryption:

```$ gpg2 --armor --symmetric example1.txt```

It asks for a passphrase, which will be used to generate the encryption key. You can use any passphrase, such as 'werkpaard', for this example. A new file example1.txt.asc is now generated which contains our ciphertext. Open it to view its contents. It should look like this:
```
-----BEGIN PGP MESSAGE-----

jA0ECQMC/C3lzWC6/jhg0k0Bbjl24c69uB/d0/yh24VbpRq00htEXlOrDFDtfOGr
yXJD1jZUZrLKc+H7wsxBrGNww2lRpt9ZmqiwngYDGI7EwHrY5iH3tSBky2pUtQ==
=Jysa
-----END PGP MESSAGE-----
```
Note: the ```--armor``` switch is used to generate ASCII (text) output to better demonstrate the result, but can be omitted in general.

Now let's remove our original plaintext.

```$ del example1.txt```

And try to recover it from the ciphertext.

```$ gpg2 -o example1.txt --decrypt example1.txt.asc```

Which should ask us for our passphrase and yield the original example1.txt. Note that we have to specify the output file first, if we want to obtain the original file. If we don't specify any file, the output is shown on the screen.

Note: if you are not asked for your passphrase, this is because GnuPG caches your passphrases (by default 10 min) so you don't have to enter them every time.

#### Asymmetric encryption ####
![Asymmetric key generation](https://upload.wikimedia.org/wikipedia/commons/3/3f/Public_key_making.svg)
![Asymmetric encryption](https://upload.wikimedia.org/wikipedia/commons/f/f9/Public_key_encryption.svg)
* Two keys
    - Public key to publish and to encrypt
    - Private key to keep secret and to decrypt
    - Easy to compute ciphertext from plaintext and public key
    - Really hard to compute plaintext (or private key) from ciphertext and public key
    - Easy to compute plaintext from ciphertext and private key
* What are problems with this setup?
* Example: [RSA][4] (1977)
* Problems: 
    - Encrypting the same plaintext twice gives the same ciphertext
    - Asymmetric encryption/decryption is much slower than symmetric

##### Example 2 - Creating a PGP keyset #####
First off, you need a strong passphrase, which will be used to encrypt your PGP keyset while 'at rest' on your harddisk. You could use a [password manager][7] to help you generate and/or store one, scribble random characters on a slip of paper or use a long phrase that is easy to remember but hard to guess. Don't worry, you can change the passphrase later. Now, we can generate our keyset.

```$ gpg2 --gen-key```
```
Please select what kind of key you want:
    (1) RSA and RSA (default)
    (2) DSA and Elgamal
    (3) DSA (sign only)
    (4) RSA (sign only)
    Your selection? 1
```
```
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
```
```
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 1y
```
```
Key expires at za 18 jun 2016 22:22:33 CEST
Is this correct? (y/N) y
```
```
GnuPG needs to construct a user ID to identify your key.

Real name: Bart Genuit
Email address: bartgenuit@gmail.com
Comment: 
```
Note: It is considered good practice to leave the comment field blank.

Note 2: You can add more e-mail addresses later.
```
You selected this USER-ID:
    "Bart Genuit <bartgenuit@gmail.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
```
A key pair should now be generated (this might take a few minutes), consisting by default of one SC (signing and certification) main key and one E (encryption) subkey.

##### Example 3 - Exporting your public key #####
We basically have two options to export our public key:

1. To a file
2. To a keyserver

In this example, we are going to use a keyserver to export our key to. First, we have to find the ID of the key we want to export

```$ gpg2 --list-keys bartgenuit```
```
pub   4096R/0x1B3940341CE0C685 2014-09-18 [expires: 2015-09-18]
      Key fingerprint = 3C0B 8C6A 7EBA 20A2 605C  38E6 1B39 4034 1CE0 C685
uid                 [ultimate] Bart Genuit <bartgenuit@gmail.com>
sub   4096R/0x7EE003C875AF686F 2014-09-18 [expires: 2015-09-18]
sub   4096R/0xD862E7132CB59274 2014-09-18 [expires: 2015-09-18]
```
The key set is identified by the main key ID, in this case, "0x1B3940341CE0C685". So, we go ahead and export this key to the standard keyserver in our configuration.

```$  gpg2 --send-keys 0x1B3940341CE0C685```
```
gpg: sending key 0x1B3940341CE0C685 to hkps server hkps.pool.sks-keyservers.net
```
And that's it, our public key is now sent to the keyserver and will be published to other keyservers, so everyone will be able to find it (for example by searching for our e-mail address). Just to be sure, we are going to put our main key IDs in a [central public key list](../pgp-workshop/publickeys.md) on GitHub.

### The PGP Encryption system ###
![PGP Diagram](https://upload.wikimedia.org/wikipedia/commons/2/2a/Wat_is_PGP_%28Pretty_Good_Privacy%29%3F.png)
Steps:
 1. Bob generates a random session key
 2. Bob encrypts the plaintext with the random session key (symmetric)
 3. Bob encrypts the session key with Alice's public key (asymmetric)
 4. Bob deletes the session key
 5. Bob sends the encrypted plaintext and encrypted session key to Alice
 6. Alice decrypts the encrypted session key with her private key (asymmetric)
 7. Alice decrypts the encrypted plaintext with the session key

* Combination of symmetric and asymmetric encryption
* Supports multiple algorithms for each step
* Problem: how can we be sure that the public key we have really belongs to Alice?

### Sending and receiving encrypted messages ###

##### Example 4 - Decrypting a message #####
I will leave a personal message for each of you in the GitHub repo, encrypted to the public key that I got from the keyserver. Get it and decrypt it.

##### Example 5 - Importing public keys #####
Same two options:

1. From a file
2. From a keyserver

In this example, we are going to use a keyserver to lookup the key we need. In a day-to-day setting, you would often not yet have the key of the person you want to send to. So, we first try to search for the key using their name or e-mail address:

```$ gpg2 --search-keys alice@wonderland.com```

If we cannot find the right key in this way, we might ask the person for their key ID and use that to import the right key. Since we put our key IDs on GitHub, we can also use that:

```$ gpg2 --recv-keys 0x1B3940341CE0C685```

**Note that we can't be sure yet that we have the right key and it was not meddled with in the transfer from Alice to Bob!**
This is why later on we are going to verify and certify the key that we obtained, and for now we don't send any sensitive information yet.

##### Example 6 - Encrypting a message #####
Once we have someone's public key, we can encrypt a message to them. Go ahead and write a message, saving it as example6.txt. Next, we are going to encrypt that message to the public key we obtained:

```$ gpg2 --armor --encrypt example6.txt --recipient 0x1B3940341CE0C685```

This will create a file example6.txt.asc which contains the ciphertext. Open it to see what it looks like. Now, you can e-mail this file to the recipient, put it on our GitHub repo, or transfer it to them in any other way.

### Key management ###
*TODO*
* Who to trust?
* Central authority vs web of trust
* Local 'web of trust'

#### Key verification and key signing (certification) ####

##### Example 6 - Verifying and signing the PGP key of someone else #####

##### Example 7 - Verifying, signing and exchanging each other's keys #####

### Message integrity (optional) ###

##### Example 8 - Encrypting and signing a message #####

##### Example 9 - Decrypting and verifying a message #####

### Extras (optional) ###

##### Example 10 - Generating a revocation certificate #####

[1]: https://www.gnupg.org
[2]: https://en.wikipedia.org/wiki/Pretty_Good_Privacy#OpenPGP
[3]: https://www.schneier.com/crypto-gram/archives/1999/0215.html#snakeoil
[4]: https://en.wikipedia.org/wiki/RSA_(cryptosystem)
[5]: https://en.wikipedia.org/wiki/Enigma_machine
[6]: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
[7]: http://www.keepass.info

### Appendix ###

#### GNU Privacy Guard ####
[GNU Privacy Guard][1] (GnuPG) is an open source and free implementation of the [OpenPGP][2] standard. It can be used to encrypt texts, e-mails, files, directories, and whole disk partitions. It is a widely used, powerful and basic tool and it will be used as the main program in this workshop to explain the basics of encryption in practice.

* Windows:
 * http://www.gpg4win.org/

* Mac:
 * `brew install gnupg2`, or
 * https://gpgtools.org/gpgsuite.html

* Linux:
 * `apt-get install gnupg2`

#### Further reading ####
##### To start with #####
* [Tutorial](https://emailselfdefense.fsf.org/en/index.html)
* [Why use PGP?](http://www.phildev.net/pgp/gpgwhy.html)
* [Reasons not to use PGP](http://secushare.org/PGP)

##### For the advanced/paranoid #####
* [PGP Best Practices](https://help.riseup.net/en/security/message-security/openpgp/best-practices)
* [Secure GnuPG configuration](https://sparkslinux.wordpress.com/2013/07/09/secure-gnupg-configuration/)
* [Coursera course Cryptography I](https://www.coursera.org/course/crypto)

##### Digital privacy #####
* [Bits of Freedom](https://www.bof.nl/)
* [Electronic Frontier Foundation](https://www.eff.org/)
* [Free Software Foundation](https://www.fsf.org/)

##### Operational security #####
* [Password strength](https://blogs.dropbox.com/tech/2012/04/zxcvbn-realistic-password-strength-estimation/)
* [VPN service](https://www.privateinternetaccess.com/)

#### Attribution ####
* "<a href="https://commons.wikimedia.org/wiki/File:Symmetric_key_encryption.svg#/media/File:Symmetric_key_encryption.svg">Symmetric key encryption</a>" by <a href="https://commons.wikimedia.org/w/index.php?title=User:Phayzfaustyn&amp;action=edit&amp;redlink=1" class="new" title="User:Phayzfaustyn (page does not exist)">Phayzfaustyn</a> - <span class="int-own-work" lang="en">Own work</span>. Licensed under <a href="http://creativecommons.org/publicdomain/zero/1.0/deed.en" title="Creative Commons Zero, Public Domain Dedication">CC0</a> via <a href="https://commons.wikimedia.org/wiki/">Wikimedia Commons</a>.
* "<a href="https://commons.wikimedia.org/wiki/File:Enigma-Machine.jpg#/media/File:Enigma-Machine.jpg">Enigma-Machine</a>" by United States Government Work - <a rel="nofollow" class="external free" href="http://www.flickr.com/photos/ciagov/5416145081/sizes/o/in/photostream/">http://www.flickr.com/photos/ciagov/5416145081/sizes/o/in/photostream/</a>. Licensed under Public Domain via <a href="//commons.wikimedia.org/wiki/">Wikimedia Commons</a>.
* "<a href="https://commons.wikimedia.org/wiki/File:Public_key_making.svg#/media/File:Public_key_making.svg">Public key making</a>". Licensed under Public Domain via <a href="https://commons.wikimedia.org/wiki/">Wikimedia Commons</a>.
* "<a href="https://commons.wikimedia.org/wiki/File:Public_key_encryption.svg#/media/File:Public_key_encryption.svg">Public key encryption</a>". Licensed under Public Domain via <a href="https://commons.wikimedia.org/wiki/">Wikimedia Commons</a>.
* "<a href="https://commons.wikimedia.org/wiki/File:Wat_is_PGP_(Pretty_Good_Privacy)%3F.png#/media/File:Wat_is_PGP_(Pretty_Good_Privacy)%3F.png">Wat is PGP (Pretty Good Privacy)?</a>" door <a href="http://nl.wikipedia.org/wiki/Bits_of_Freedom" class="extiw" title="nl:Bits of Freedom">Bits of Freedom</a> - <a rel="nofollow" class="external free" href="https://toolbox.bof.nl/">https://toolbox.bof.nl/</a>. Licentie <a href="http://creativecommons.org/licenses/by-sa/3.0" title="Creative Commons Attribution-Share Alike 3.0">CC BY-SA 3.0</a> via <a href="https://commons.wikimedia.org/wiki/">Wikimedia Commons</a>.

#### Licence ####
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons-Licentie" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">Practical Encryption workshop</span> van <a xmlns:cc="http://creativecommons.org/ns#" href="https://github.com/aosavi/hackerspace-onezero/blob/master/pgp-workshop/pgp-workshop.md" property="cc:attributionName" rel="cc:attributionURL">Bart Genuit</a> is in licentie gegeven volgens een <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Naamsvermelding 4.0 Internationaal-licentie</a>.
