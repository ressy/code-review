# We'll use some built-in R and some stringr.
library(stringr)

#### A few more pieces of theory

# POSIX vs PCRE vs Base vs Extended ...?
#
# ?regexpr:
#   "Two types of regular expressions are used in R, extended regular expressions
#   (the default) and Perl-like regular expressions used by perl = TRUE."
#   (lots more documentation here on Extended vs PCRE in R.)
#
# what about in stringr?  stringr is based on stringi which uses "ICU Java-like
# regular expressions".  From http://userguide.icu-project.org/strings/regexp :
#   "The regular expression patterns and behavior are based on Perl's regular
#   expressions."
#
# When in doubt, aim for Perl-compatible and don't worry too much.


#### Character classes

# A few from ?regexp:
# [:lower:]    Lower-case letters in the current locale
# [:upper:]    Upper-case letters in the current locale
# [:alpha:]    [:lower:] and [:upper:]
# [:alnum:]    [:alpha:] and [:digit:]
# [:alnum:]    0-9A-Za-z
# [:xdigit:]   Hexadecimal digits
# [:print:]    Printable characters: [:alnum:], [:punct:] and space

# Example: Pick out hexadecimal integers from strings.

stats <- c('Beef 12 #7c5825', 'Apples #dd1a1d 17', '#fceff0 --', 'Missing ID')
# whoops, this matches some words too:
str_match(stats, '[:xdigit:]+')
# better:
str_match(stats, '#([:xdigit:]+)')
# or, matching by length:
str_match(stats, '[:xdigit:]{6}')
# Note the differences between stringr's functions and base R:
grep('[[:xdigit:]]{6}', stats)

# Weirder example: Do any of my strings have non-printing characters?

strings <- c('some text','a\r tricky\r case','some more text')
grep('[^[:print:]]', strings, value=T) # note the extra brackets


#### Character ranges and range ordering

# Example: [:alnum:] vs 0-9A-Za-z

identifiers <- c('X106', 'Z195', 'Y37', 'A118', 'C57', 'a37', 'x93')
# We can use the built-in alphanumeric class, or make our own ranges if those
# don't fit the need:
grep('[[:alnum:]]+', identifiers, value=T)
grep('[X-Z][0-9]+', identifiers, value=T)
# If we want a case-insensitive match, we can use a case sensitivity flag, or
# just give another character range.
grep('[X-Zx-z][0-9]+', identifiers, value=T)
grep('[X-Z][0-9]+', identifiers, value=T, ignore.case=T)
# ...but what does it mean to say "from one character to another" for a custom
# range?

# Weirder example: custom ranges

# % is in the range from ! to (
grep('^[!-(]$', '%')
# but ) is beyond that range
grep('^[!-(]$', ')')

# Even weirder example: unexpected ranges

# A-z spans a few extra characters you wouldn't expect!
grep('^[A-z]$', '_')

# It's the numeric (ordinal) value of the characters that matters. From here you
# can go down a rabbit hole of character sets and locales and encodings, but
# that's probably enough for now.


#### Some specific examples

# Matching custom filename patterns

datafiles <- c("data/project1/PCMP_SCID00007.NP.1.1_R1.fastq.gz",
"data/project1/PCMP_SCID00007.NP.1.1_R2.fastq.gz",
"data/project1/PCMP_SCID00007.NP.2.1_R1.fastq.gz",
"data/project1/PCMP_SCID00007.NP.2.1_R2.fastq.gz",
"data/project1/PCMP_SCID00007.NP.3.1_R1.fastq.gz",
"data/project1/PCMP_SCID00007.NP.3.1_R2.fastq.gz",
"data/project1/PCMP_SCID00007.OP.1.1_R1.fastq.gz",
"data/project1/PCMP_SCID00007.OP.1.1_R2.fastq.gz",
"data/project1/PCMP_SCID00007.OP.2.1_R1.fastq.gz",
"data/project1/PCMP_SCID00007.OP.2.1_R2.fastq.gz",
"data/project1/PCMP_SCID00007.OP.3.1_R1.fastq.gz",
"data/project1/PCMP_SCID00007.OP.3.1_R2.fastq.gz",
"data/project2/PCMP_SCID00007.ST.1.1_R1.fastq.gz",
"data/project2/PCMP_SCID00007.ST.1.1_R2.fastq.gz",
"data/project2/PCMP_SCID00007.ST.2.1_R1.fastq.gz",
"data/project2/PCMP_SCID00007.ST.2.1_R2.fastq.gz",
"data/project2/PCMP_SCID00007.ST.3.1_R1.fastq.gz",
"data/project2/PCMP_SCID00007.ST.3.1_R2.fastq.gz",
"data/project3/PCMP_SCID00007somethingelse_R1.fastq.gz",
"data/project3/PCMP_SCID00007somethingelse_R2.fastq.gz")


# This will capture three specific parts of each string: the project directory
# number, the two-character sample type, and the R1/R2 value.  But it doesn't
# quite work for all cases.
str_match(filepaths, "project(.)/PCMP_SCID[0-9]+.(..)..*_R([12]).fastq.gz")
# The periods match any character since they have special meaning.  So we can
# escape them so they mean a literal ".":
str_match(filepaths, "project(.)/PCMP_SCID[0-9]+\.(..)\..*_R([12])\.fastq\.gz")
# But wait, R itself will interpret \. as an attempt to escape a special
# character. So we can escape the escapes, and now it works:
str_match(filepaths, "project(.)/PCMP_SCID[0-9]+\\.(..)\\..*_R([12])\\.fastq\\.gz")

# Indexing off of grep's output

names(datafiles) <- c("@D00728:19:C8E37ANXX:8:2214:2692:2345 1:N:0:AGGCAGAA+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:2692:2345 2:N:0:AGGCAGAA+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:10085:2240 1:N:0:GGACTCCT+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:10085:2240 2:N:0:GGACTCCT+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:10507:2238 1:N:0:TAGGCATG+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:10507:2238 2:N:0:TAGGCATG+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:1672:2179 1:N:0:CGAGGCTG+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:1672:2179 2:N:0:CGAGGCTG+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:1443:2184 1:N:0:AAGAGGCA+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:1443:2184 2:N:0:AAGAGGCA+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:2294:2179 1:N:0:GTAGAGGA+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:2294:2179 2:N:0:GTAGAGGA+ACTGCATA",
                      "@D00728:19:C8E37ANXX:8:2214:1234:2234 1:N:0:TAAGGCGA+AAGGAGAA",
                      "@D00728:19:C8E37ANXX:8:2214:1234:2234 2:N:0:TAAGGCGA+AAGGAGAA",
                      "@D00728:19:C8E37ANXX:8:2214:1236:2207 1:N:0:CGTACTAG+AAGGAGTA",
                      "@D00728:19:C8E37ANXX:8:2214:1236:2207 2:N:0:CGTACTAG+AAGGAGTA",
                      "@D00728:19:C8E37ANXX:8:2214:1488:2227 1:N:0:AGGCAGAA+AAGGAGTA",
                      "@D00728:19:C8E37ANXX:8:2214:1488:2227 2:N:0:AGGCAGAA+AAGGAGTA",
                      "@D00728:19:C8E37ANXX:8:2214:1488:2227 1:N:0:AGGCAGAA+AAGGAGTA",
                      "@D00728:19:C8E37ANXX:8:2214:1488:2227 2:N:0:AGGCAGAA+AAGGAGTA")

names(datafiles)[grep('/PCMP_SCID00007\\.ST\\..*\\.fastq\\.gz', datafiles)]
datafiles[grep('AGGCAGAA', names(datafiles))]

# An example from John: matching across a list of patterns

string <- 'My black cat ran away.'
patterns <- list(p1='black',
                 p2='[tac]+\\s+[nar]+',
                 p3='\\S+')

null <- mapply(function(p, pName){
  m <- str_match_all(string, p)
  m <- paste0(unlist(m), collapse=' AND ')
  cat(pName, ' matches: ', m, '\n')
  
}, patterns, names(patterns))

# Building patterns from strings (and what can go wrong)

# A weird case: 


#### Implementations outside of R

bashscript <- "
#!/usr/bin/env bash

# An example from Kevin, to parse CIGAR strings in bash.
# uses some grep features:
#   -o: print only the matching part of each line
#   -P: perl-compatible regular expressions
# note how this finds and prints multiple separate matches for this one line!

CIGAR=45S155M2D3S
echo ${CIGAR} | grep -o -P '([0-9]+)([A-Z])'

# An example of munging fastq description lines in sed.
# For sed, we need -r to get extended regular expressions, for backreferences (\1)
# (Why bother with a backreference at all, rather than just doing a substitution
# directly?  Because I want to ensure the match finds the space after capture
# group 1, so we're not matching the quality score line.)

DESC='@HWI-ST423:258:C0MLUACXX:5:1101:1235:2219 1:N:0:ATCACG'
echo $DESC | sed -r 's/^(@.*?) .*$/\1/'
"

#### References and tools

