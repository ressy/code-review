# Jesse Connell
# 2018-02-07
# Code Review
# Function of the Week: [ (and [[ and $)

# The brackets are really functions! --------------------------------------

# Help lookup is like any other:
?`[`

# They have optional arguments (more below)

# Functional programming with things like lapply:
x <- list(1:3, 4, 9:10)
lapply(x, `[`, 1:2)

# Or do.call (get the element in one corner of a 3D box)
box <- array(1:27, dim = c(3,3,3))
do.call(`[[`, c(list(box), dim(box)))

# Some Indexing Basics ----------------------------------------------------

### The Official Options:
#   numeric
#   logical
#   character
#   empty

x <- 1:10
names(x) <- letters[1:10]

### Numeric Indexing
# Mostly What you'd expect.  Watch out for numeric-like characters though!

# zero implies empty, or NULL.  Selects nothing.
x[0]
x[NULL]
x[integer()]

# negatives select all but the given index values
x[-1]

# can't mix neg and pos though
try(x[c(-1, 1)])

# watch out for empty negatives!  This can come up if you're building your index
# vector programmatically and at some point happen to have no entries to remove.
# Instead you'll remove everything!
x[-integer()]

# NA in gives NA out by definition
x[NA]

### Logical Indexing

# I think this one doesn't have too many gotcha's.
# Simple case, TRUE for x < 5 and FALSE otherwise:
x[ x < 5 ]

# One interesting effect is the "recycling" for short inputs.
# You can select every other entry:
x[ c(TRUE, FALSE) ]
# Or skip every third:
x[ c(TRUE, TRUE, FALSE) ]
# I think that's actually more readable than my usual insinct to use modulus for
# cyclic things:
x[ x%%3 != 0 ]

### Character Indexing

# The infamous names().  Names are character by definition (Note: default
# "integer" row names on a data frame).  Many other nitpicky rules can trip you
# up too.
names(x) <- c("", letters[x[-1]])
x[""] # Empty string gives NA by definition!
# Ugh!  More on names below

### Empty Indexing

# Distinct case from 0/NULL/zero-length vector of before: just keep everything 
# along a dimension.  Not much new to see here, moving on.
x[]

### Wait, what about Factor Indexing?
# That's not in the list of input types.  But it clearly works.

observations <- factor(c("Medium", "Small", "Large", "Large"),
                       levels = c("Small", "Medium", "Large"))
cases <- c("S", "M", "L")
# Why does this even work?  cases has no names and the text doesn't match up.
cases[observations]

# Factor arguments to [ are handled as integers, not characters!  It takes the
# ID codes assigned to the levels.  Be careful with factor levels!

# Another example:
vals <- exp(-seq(0, 10, 0.01))
bins <- cut(vals, breaks = 3)
cases[bins] # same deal
table(bins)
table(cases[bins])

# Arguments ---------------------------------------------------------------

things <- data.frame(Weight=c(100, 1, 50),
                     Height=c(20, 5, 4),
                     Color=c("red", "blue", "green"))

### "drop"

# [.data.frame gives you a data frame back out as you'd expect:
things[1, ]

# Not always with matrices:
mat <- as.matrix(things[, 1:2])
mat[1, ]
class(mat[1, ])

# It's "helping" you by removing stub dimensions.
# Instead you can do:
mat[1, , drop=FALSE]
class(mat[1, , drop=FALSE])

### "exact"

# exact seems to allow fuzzy-matching for [[:
things[["Weight", exact = TRUE]]
things[["Wei", exact = TRUE]]
things[["Wei", exact = FALSE]]

# I don't much like that idea, but note:
# exact=FALSE by default for `$`!
things$Wei

# Lookup Tables -----------------------------------------------------------

### With Integers: Kevin's TRUE/FALSE example: map TRUE to one word and FALSE to
### another.
bools <- sample(c(TRUE, FALSE), size = 10, replace = TRUE)
bools
# works because as.integer(FALSE) is 0, as.integer(TRUE) is 1
c("No", "Yes")[bools+1]

### With Characters? A data frame of attributes
attrs <- data.frame(Category=c("A", "B", "C", "D"),
                    Dosage=c(5, 20, 80, 320))
# careful...
rownames(attrs) <- attrs$Category

obs <- data.frame(SampleID = 100 + 1:10,
                  SampleCategory = sample(c("A", "B", "C", "D"),
                                          size = 10,
                                          replace = TRUE))

# If we let a factor be created implicitly this may not do quite what we expect.
# This is not character (name) indexing!
cbind(obs, attrs[obs$SampleCategory, ])

# What if our levels aren't identical?
obs$SampleCategory <- factor(obs$SampleCategory, levels = c("D", "C", "B", "A"))
# No warning signs, just incorrect!
cbind(obs, attrs[obs$SampleCategory, ])
# If we explicitly given character input to `[` it does the expected thing.
cbind(obs, attrs[as.character(obs$SampleCategory), ])

# More on Names -----------------------------------------------------------

# You can eliminate names on a vector or matrix (with names(x) <- NULL) but not
# rownames on a data frame.

# Back to the table of three things, the first entry is the large red one,
# right?
things[1, ]

# Let's re-order by weight.
things <- things[order(things$Weight), ]
things

# Now the first entry is the small blue one.
things[1, ]
# But the row names on the left are storing the ordering; it still says 2 for
# the blue one.

# Aha, the row name "1" is distinct from the row with index 1.  The row with 
# name "1" is still the big red one.  Yet again watch out for (character) names
# versus (integer) indexes!
things["1", ]

# At least R is conceptually consistent, right?
1 == "1" # ...oh well.

# Ideas for how to handle names for data frames:
# 1) Just don't! (Use match, left_join, etc. on columns instead)
# 2) Use R's names as the canonical truth when pairing up objects (however it 
#    happens to mess with the names) and make sure you're using character data
# 3) Make a wrapper function specific to your case to give predictable names. 
#    See make.unique(), make.names().
