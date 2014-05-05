#!/usr/bin/python
import re
import os
import sys
import scipy
import argparse
from HTMLParser import HTMLParser
from nltk.tokenize.treebank import TreebankWordTokenizer
from nltk.tokenize.punkt import PunktSentenceTokenizer
from nltk.tag.stanford import StanfordTagger
from nltk.stem.snowball import SnowballStemmer


def squeeze_whitespace(data):
    # Replace every whitespace segment with a space.
    return re.sub(r'\s+', ' ', data).strip()

def repeated_search(block, pattern, group):
    # Search for pattern in block, repeatedly removing
    # a particular group from the match.
    match = pattern.search(block)
    while match:
        block = block[:match.start(group)] + block[match.end(group):]
        match = pattern.search(block)

    return squeeze_whitespace(block)

# Create a subclass for debate parsing and override the handler methods.
class SpeechHTMLParser(HTMLParser):

    def __init__(self):
        fun = getattr(HTMLParser, '__init__', lambda x: None)
        fun(self)
        self.bdepth = 0
        self.speaker = ''
        self.block = []
        self.text = []

        self.entityrefs = {'quot': '\"', 'lsquo': '\'', 'rsquo': '\'', 'ldquo': '\"', 'rdquo': '\"', 'ndash': ' -- ', 'hellip': ' ... ', 'iuml': 'i', 'mdash': ' --- ', 'eacute': 'e', 'oacute': 'o', 'amp': '&'}
        self.charrefs = {'8217': '\'', '8242': '\'', '8220': '\"', '8221': '\"', '8211': ' -- ', '8230': ' ... ', '8212': ' --- ', '8216': '\'', '8217': '\'', '038': '&', '38': '&'}

    def record_data(self):
        self.text.append((squeeze_whitespace(self.speaker), \
                              squeeze_whitespace(' '.join(self.block))))

    def close(self):
        self.record_data()
        fun = getattr(HTMLParser, 'close', lambda x: None)
        fun(self)

    def handle_starttag(self, tag, attrs):
        if tag == 'b':
            if self.bdepth == 0:
                # Record the speaker's name and their speech.
                self.record_data()

                # Reset temp variables for the next speaker.
                self.speaker = ''
                self.block = []
            self.bdepth += 1
        elif tag != 'p' and tag != 'i':
            raise Exception('Non-paragraph, non-bold/italic tag encountered: ' + tag)
    
    def handle_endtag(self, tag):
        if tag == 'b':
            if self.bdepth == 0:
                raise Exception('Bold region ended before being started.')
            else:
                self.bdepth -= 1
        elif tag != 'p' and tag != 'i':
            raise Exception('Non-paragraph, non-bold/italic tag encountered: ' + tag)
       
    def handle_data(self, data):
        # Don't bother keeping just whitespace.
        if len(data) == 0 or data.isspace():
            return

        # Append to either the speaker's name or their speech.
        if self.bdepth == 0:
            self.block.append(data)
        else:
            self.speaker += ' ' + data

    def handle_entityref(self, name):
        self.block.append(self.entityrefs[name])

    def handle_charref(self, name):
        self.block.append(self.charrefs[name])


# Main method.
def main(sysargs):
    sys.argv = sysargs
    arg_parser= argparse.ArgumentParser(description='Formats debates by removing HTML and filtering words.')
    arg_parser.add_argument('-i', '--infile', required=True, help='Debate file to format.')
    args = arg_parser.parse_args()

    # Initialize nltk elements.
    parser = SpeechHTMLParser()
    sent_splitter = PunktSentenceTokenizer()
    tokenizer = TreebankWordTokenizer()
    tagger_loc = '/het/users/jengi/stanford-postagger/'
    tagger = StanfordTagger(tagger_loc + 'models/wsj-0-18-bidirectional-distsim.tagger', \
                                tagger_loc + 'stanford-postagger.jar')
    stemmer = SnowballStemmer('english')

    # Read infile.
    speaker_pattern = re.compile('.*:')
    null_pattern = re.compile('\s*(\[[^\]]*\]|\([^\)]*\))')
    dash_pattern = re.compile('\S+(--)\s+')
    ellipse_pattern = re.compile('\s*\.\.\.\s*')
    noun_tags = ['NN', 'NNS', 'NNP', 'NNPS']
    punct = ['!', '"', '#', '$', '%', '&', "'", '(', ')', '*', '+', ',', \
                 '-', '.', '/', ':', ';', '<', '=', '>', '?', '@', '[', \
                 '\\', ']', '^', '_', '`', '{', '|', '}', '~']
    block_lengths = []
    with open(args.infile, 'r') as afile:
        file_contents = afile.read()
        parser.feed(file_contents)
        parser.close()

        num_blocks = 0
        speeches = {}
        for (speaker, block) in parser.text:
            if num_blocks % 10 == 0:
                print >> sys.stderr, 'Processing block ' + str(num_blocks) + ' ...'
            orig_block = block

            # Remove applause, laughter, etc.
            block = repeated_search(block, null_pattern, 0)

            # Remove -- from the end of words.  (Indicates stuttering / stopping.)
            block = repeated_search(block, dash_pattern, 1)

            # Do more complex tokenization.
            sents = sent_splitter.tokenize(block)
            sents = [ellipse_pattern.sub(' ... ', sent) for sent in sents]
            tokens = [tokenizer.tokenize(sent) for sent in sents]

            # Run POS tagger and keep only nouns.
            # Also lowercase and stem these nouns.
            tags = [tagger.tag(toks) for toks in tokens]
            tokens = []
            tagged_text = [];
            for sent in tags:
                tokens.append([])
                for (word, tag) in sent:
                    tagged_text.append(word);
                    tagged_text.append(tag);
                    if tag in noun_tags:
                        tokens[len(tokens) - 1].append(stemmer.stem(word.lower()))

            # Remove any "sentences" that are actually empty and
            # any tokens that are pure punctuation.
            for i in reversed(range(len(tokens))):
                for j in reversed(range(len(tokens[i]))):
                    non_punct = ''.join([tok for tok in tokens[i][j] if tok not in punct])
                    if len(non_punct) == 0:
                        del tokens[i][j]

                if len(tokens[i]) == 0:
                    del tokens[i]

            # Make sure there is still at least one sentence left.
            num_sents = len(tokens)
            if num_sents == 0:
                continue

            # Add block to speeches dictionary.
            speaker = speaker[:speaker_pattern.match(speaker).end() - 1]
            if speaker not in speeches:
                speeches[speaker] = []
            speeches[speaker].append(orig_block)
            speeches[speaker].append(' '.join(tagged_text))
            speeches[speaker].append('\n'.join([' '.join(sent) for sent in tokens]))
            #print speeches[speaker][0]
            #print speeches[speaker][1]
            #print speeches[speaker][2]

            num_blocks += 1
            num_tokens = 0
            for toks in tokens:
                num_tokens += len(toks)
            block_lengths.append(num_tokens)

    # Save each speaker's text to a file.
    (infolder, basename) = os.path.split(os.path.abspath(args.infile))
    out_prefix = infolder + '/'
    out_suffix = basename
    for speaker in speeches:
        # Create outfile prefixed by speaker's name.
        outfile = open(out_prefix + speaker + '-' + out_suffix, 'w')

        # Save text to outfile.
        blocks = speeches[speaker]
        for i in range(0, len(blocks), 3):
            print >> outfile, blocks[i]
            print >> outfile, blocks[i + 1]
            print >> outfile, blocks[i + 2]
            print >> outfile

        outfile.close()

    print '# of blocks: ' + str(num_blocks)
    print 'Mean # of tokens (per block): ' + str(scipy.mean(block_lengths))
    print 'Median # of tokens: ' + str(scipy.median(block_lengths))
    print 'Standard deviation in # of tokens: ' + str(scipy.std(block_lengths))


# (To start in the main method.)
if __name__ == "__main__":
    main(sys.argv)
