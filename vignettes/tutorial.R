## ---- echo=TRUE, eval=FALSE, cache=FALSE---------------------------------
#  install.packages('genderizeR')

## ---- echo=TRUE, eval=FALSE, cache=FALSE---------------------------------
#  # install.packages('devtools')
#  devtools::install_github("kalimu/genderizeR")

## ---- echo=TRUE, eval=TRUE, cache=FALSE, results='hide', message=FALSE----
library(genderizeR)

## ---- echo=TRUE, eval=FALSE, cache=FALSE---------------------------------
#  news(package = 'genderizeR')

## ---- echo=TRUE, eval=FALSE, cache=FALSE---------------------------------
#  help(package = 'genderizeR')
#  ?textPrepare
#  ?findGivenNames
#  ?genderize

## ---- echo=TRUE, eval=TRUE, cache=TRUE-----------------------------------
# An example of a character vector of strings
x = c("Winston J. Durant, ASHP past president, dies at 84",
"JAN BASZKIEWICZ (3 JANUARY 1930 - 27 JANUARY 2011) IN MEMORIAM",
"Maria Sklodowska-Curie")
 
# Search for terms that could be first names.
# If you have your API key you can authorize access to the API with apikey argument
# e.g. findGivenNames(x, progress = FALSE, apikey = 'your_api_key').
givenNames = findGivenNames(x, progress = FALSE)

# We can use only terms that have more than x counts in the database 
# to eliminate noise in gender data.
givenNames = givenNames[count > 100]
givenNames

# Genderize the original character vector.
genderize(x, genderDB = givenNames, progress = FALSE)

# We have got it right!


## ---- echo=TRUE, eval=TRUE, cache=TRUE-----------------------------------
# Let's work with some block of text with some given names inside
x = "Tom did play hookey, and he had a very good time. He got back home 
     barely in season to help Jim, the small colored boy, saw next-day's wood 
     and split the kindlings before supper-at least he was there in time 
     to tell his adventures to Jim while Jim did three-fourths of the work. 
     Tom's younger brother (or rather half-brother) Sid was already through 
     with his part of the work (picking up chips), for he was a quiet boy, 
     and had no adventurous, trouble-some ways. While Tom was eating his
     supper, and stealing sugar as opportunity offered, Aunt Polly asked 
     him questions that were full of guile, and very deep-for she wanted 
     to trap him into damaging revealments. Like many other simple-hearted
     souls, it was her pet vanity to believe she was endowed with a talent 
     for dark and mysterious diplomacy, and she loved to contemplate her 
     most transparent devices as marvels of low cunning. 
     (from 'Tom Sawyer' by Mark Twain)"

# We could send it to the findGivenNames() function as it is, 
# but let's see what textPrepare() function does for us.

(xPrepared = textPrepare(x))
# We got all unique terms (at least 2 characters long) which can be our 
# candidates for given names.

# If we using free API plan, it will be better to apply a list of stopwords 
# to use fewer API requests. Let's use some simplified one and remove 
# some of terms.
xPrepared = xPrepared[!xPrepared %in% c("before", "from", "had", "her", "in", 
"no", "that", "with", "at", "him", "into", "of", "the", "to", "he", "his", 
"it", "up", "for", "got", "as", "by", "did", "or", "was", "and", "back", "she")]

# Now we are ready to look for terms that will be our candidates for given names.

## ---- echo=TRUE, eval=TRUE, cache=TRUE-----------------------------------
# Use the findGivenNames() function to connect with the API.

(givenNames = findGivenNames(xPrepared, progress = FALSE))

# We have found more than thirty terms in the genderize.io database, but 
# many of them introduce only noise to gender data. We can remove them by setting 
# higher threshold of "count" parameter. By doing that we obtain more reliable results.

givenNames[givenNames$count > 100]

# Yes! We have got it right.


## ---- echo=TRUE, eval=FALSE, cache=TRUE----------------------------------
#  # If you work with free API plan you are limited to 1000 gueries a day.
#  # If your vector of terms to check is quite large we may want to
#  # somehow cache the results when you reach the limit and start from
#  # that point the next day.
#  
#  # When you reached the limit you will get a message...
#  givenNames_part1 = findGivenNames(xPrepared)
#  
#  # Terms checked: 10/86. First names found: 4.          |   0%
#  # Terms checked: 20/86. First names found: 7.          |  11%
#  # Terms checked: 30/86. First names found: 12.         |  22%
#  # Terms checked: 40/86. First names found: 17.         |  33%
#  # Terms checked: 50/86. First names found: 22.         |  44%
#  # Terms checked: 60/86. First names found: 25.         |  56%
#  #   |=================================                 |  67%
#  #  Client error: (429) Too Many Requests (RFC 6585)
#  #  Request limit reached
#  #
#  # The API queries stopped at 57 term.
#  # If you have reached the end of your API limit, you can start the function again from that term and continue finding given names next time with efficient use of the API.
#  #  Remember to add the results to already found names and not to overwrite them.
#  #
#  # Warning messages:
#  # 1: In genderizeAPI(termsQuery, apikey = apikey, ssl.verifypeer = ssl.verifypeer) :
#  #   You have used all available requests in this subscription plan.
#  # 2: In findGivenNames(xPrepared) : The API queries stopped.
#  
#  # You can see that the query stopped at 57 term in this case.
#  # We can use it tomorrow:
#  givenNames_part2 = findGivenNames(xPrepared[57:NROW(xPrepared)])
#  
#  # Finally, we can bind all parts together.
#  givenNames = rbind(givenNames_part1, givenNames_part2)
#  

## ---- echo=TRUE, eval=FALSE, cache=TRUE----------------------------------
#  # Genderize.io API uses UTF-8 encoding. We can also set specific locale.
#  Sys.setlocale("LC_ALL", "Polish")
#  (x = "R�za")
#  # [1] "R�za"
#  (xp = textPrepare(x))
#  # [1] "r�za"
#  findGivenNames(x, progress = FALSE)
#  #    name gender probability count
#  # 1: r�za female        0.89    28

## ---- echo=TRUE, eval=FALSE, cache=TRUE----------------------------------
#  
#  # Let's say we have a character string with a first name within.
#  x = 'Pascual-Leone Pascual, Ana Ma'
#  
#  # There are four unique terms that will be checked in the API database.
#  textPrepare(x)
#  # [1] "ana"     "leone"   "ma"      "pascual"
#  
#  # Let's don't assume which term is a given name and run through the API
#  # all four terms.
#  (genderDB = findGivenNames(x, progress = FALSE))
#  #       name gender probability count
#  # 1:     ana female        0.99  3621
#  # 2:   leone female        0.81    27
#  # 3:      ma female        0.62   251
#  # 4: pascual   male        1.00    26
#  
#  # Having data table with gender data, we can try to "genderize" the whole string.
#  genderize(x, genderDB = genderDB, progress = FALSE)
#  #                             text givenName gender genderIndicators
#  # 1: Pascual-Leone Pascual, Ana Ma       ana female                4
#  
#  # The output shows that we used 4 terms as gender indicators and the algorithm
#  # used most common term "ana" as final indicator of gender.
#  
#  # What about double first names like "Hans-Peter"?
#  x = 'Hans-Peter'
#  
#  (genderDB = findGivenNames(x, progress = FALSE))
#  #     name gender probability count
#  # 1:  hans   male        0.99   431
#  # 2: peter   male        1.00  4373
#  genderize(x, genderDB = genderDB, progress = FALSE)
#  #          text givenName gender genderIndicators
#  # 1: Hans-Peter     peter   male                2
#  
#  # The classification algorithm predict "Hans-Peter" as male using the most
#  # common first name of the two.
#  
#  # Localization
#  
#  findGivenNames("andrea", country = "us")
#  #      name gender probability count
#  # 1: andrea female        0.97  2308
#  
#  findGivenNames("andrea", country = "it")
#  #      name gender probability count
#  # 1: andrea  male         0.99  1070
#  
#  findGivenNames("andrea", language = "en")
#  #      name gender probability count
#  # 1: andrea female        0.96  2562
#  
#  findGivenNames("andrea", language = "it")
#  #      name gender probability count
#  # 1: andrea   male        0.99  1070
#  

## ---- echo=TRUE, eval=FALSE, cache=TRUE----------------------------------
#  # Let's calculate now some metrics of gender prediction efficiency
#  # on an exemplary random sample.
#  
#  set.seed(238)
#  labels = sample(c('male', 'female', 'unknown'), size = 100, replace = TRUE)
#  predictions = sample(c('male', 'female', NA), size = 100, replace = TRUE)
#  
#  indicators = classificationErrors(labels, predictions)
#  # Confusion matrix for the generated sample
#  indicators[['confMatrix']]
#  #          predictions
#  # labels    female male <NA>
#  #   female      12   10    4
#  #   male         7   10   12
#  #   unknown     16   13   16
#  #   <NA>         0    0    0
#  
#  # The "errorCoded" is total classification error that takes into account
#  # observations with known gender labels ("female" and "male")
#  # which cannot be automatically classified ("NA").
#  # errorCoded = (7 + 10 + 4 + 12) / (12 + 10 + 4 + 7 + 10 + 12)
#  unlist(indicators['errorCoded'])
#  # errorCoded
#  #        0.6
#  
#  # The "errorCodedWithoutNA" takes into account only those observations
#  # in which gender prediction was possible.
#  # errorCodedWithoutNA = (7 + 10) / ( 12 + 10 + 7 + 10)
#  unlist(indicators['errorCodedWithoutNA'])
#  # errorCodedWithoutNA
#  #           0.4358974
#  
#  # The "naCoded" is the proportion of observations without gender predictions.
#  # It doesn't take into account predictions for labels "unknown";
#  # If a human coder couldn't classified such observation we shouldn't
#  # penalize our algorithm for trying.
#  # naCoded = (4 + 12) / ( 12 + 10 + 4 + 7 + 10 + 12)
#  unlist(indicators['naCoded'])
#  #   naCoded
#  # 0.2909091
#  
#  # The "errorGenderBias" is robust for situations when we misclassify
#  # the same number of female as male and male as female.
#  # If it is close to zero we can assume that misclassified observations
#  # won't affect much our estimates of true gender proportions.
#  # errorGenderBias = (7 - 10) / (12 + 10 + 7 + 10)
#  unlist(indicators['errorGenderBias'])
#  # errorGenderBias
#  #     -0.07692308

## ---- echo=TRUE, eval=FALSE, cache=TRUE----------------------------------
#  
#  
#  # Let's look for optimal set of parameters for gender prediction
#  # suitable for genderizing "authorship" dataset in the package.
#  data(authorships)
#  head(authorships[, c(4, 5)],15)
#  #              value genderCoded
#  # 2636  Morison, Ian        male
#  # 2637 Hughes, David        male
#  # 2638 Higson, Roger        male
#  # 2639    CONDON, HA      noname
#  # 2640  GILCHRIST, E      noname
#  # 2641     Haury, LR      noname
#  
#  # In the genderizeR package we have prepared gender data for that set as well.
#  tail(givenNamesDB_authorships)
#  #      name gender probability count
#  # 1:     yv   male        1.00     1
#  # 2:   yves   male        0.98   153
#  # 3: zdenek   male        1.00    30
#  # 4:  zhang   male        0.60    30
#  # 5:    zhu   male        0.67     6
#  # 6:     zy female        0.50     2
#  
#  # We can define values for probabilities and counts that will be used
#  # for building the grid of possible combinations of these parameters.
#  probs = c(0.5, 0.7, 0.8, 0.9, 0.95, 0.97, 0.98, 0.99, 1)
#  counts = c(1, 10, 100)
#  
#  x = authorships$value
#  y = authorships$genderCoded
#  
#  authorshipsGrid =
#      genderizeTrain(x = x, y = y,
#                     givenNamesDB = givenNamesDB_authorships,
#                     probs = probs, counts = counts,
#                     parallel = TRUE)
#  
#  authorshipsGrid
#  #     prob count errorCoded errorCodedWithoutNA    naCoded errorGenderBias
#  #  1: 0.50     1 0.07093822          0.03791469 0.03432494     0.014218009
#  #  2: 0.70     1 0.08466819          0.03147700 0.05491991     0.007263923
#  #  3: 0.80     1 0.10983982          0.03233831 0.08009153     0.012437811
#  #  4: 0.90     1 0.11899314          0.03022670 0.09153318     0.015113350
#  #  5: 0.95     1 0.13272311          0.02820513 0.10755149     0.012820513
#  #  6: 0.97     1 0.14645309          0.02610966 0.12356979     0.010443864
#  #  7: 0.98     1 0.15560641          0.02638522 0.13272311     0.010554090
#  #  8: 0.99     1 0.18306636          0.02724796 0.16018307     0.005449591
#  #  9: 1.00     1 0.27459954          0.03353659 0.24942792    -0.003048780
#  # 10: 0.50    10 0.12128146          0.03759398 0.08695652     0.017543860
#  # 11: 0.70    10 0.13958810          0.02842377 0.11441648     0.007751938
#  # 12: 0.80    10 0.16247140          0.02917772 0.13729977     0.013262599
#  # 13: 0.90    10 0.16933638          0.02680965 0.14645309     0.016085791
#  # 14: 0.95    10 0.18535469          0.02465753 0.16475973     0.013698630
#  # 15: 0.97    10 0.19908467          0.02234637 0.18077803     0.011173184
#  # 16: 0.98    10 0.20823799          0.02259887 0.18993135     0.011299435
#  # 17: 0.99    10 0.23569794          0.02339181 0.21739130     0.005847953
#  # 18: 1.00    10 0.33180778          0.02666667 0.31350114     0.000000000
#  # 19: 0.50   100 0.27459954          0.03058104 0.25171625     0.012232416
#  # 20: 0.70   100 0.29061785          0.02821317 0.27002288     0.009404389
#  # 21: 0.80   100 0.30892449          0.02893891 0.28832952     0.016077170
#  # 22: 0.90   100 0.31350114          0.02912621 0.29290618     0.016181230
#  # 23: 0.95   100 0.32036613          0.02941176 0.29977117     0.016339869
#  # 24: 0.97   100 0.32951945          0.02657807 0.31121281     0.013289037
#  # 25: 0.98   100 0.33638444          0.02684564 0.31807780     0.013422819
#  # 26: 0.99   100 0.36613272          0.02807018 0.34782609     0.007017544
#  # 27: 1.00   100 0.45995423          0.02880658 0.44393593     0.004115226
#  #     prob count errorCoded errorCodedWithoutNA    naCoded errorGenderBias
#  
#  
#  # If we want to minimize "errorCoded" choosing standard prob=0.5 and count=1
#  # gives us the smallest possible value.
#  authorshipsGrid[authorshipsGrid$errorCoded == min(authorshipsGrid$errorCoded),]
#  
#  #     prob count errorCoded errorCodedWithoutNA   naCoded errorGenderBias
#  # 1:  0.5     1 0.07093822          0.03791469 0.03432494      0.01421801
#  
#  # However, if we would like to minimize "errorCodedWithoutNA" we should
#  # choose prob = 0.97 and count = 10. The trade off is that the proportion
#  # of observation with unpredicted gender ("naCodded") will greatly increase.
#  # authorshipsGrid[authorshipsGrid$errorCodedWithoutNA ==
#                          min(abs(authorshipsGrid$errorCodedWithoutNA)),]
#  
#  #    prob count errorCoded errorCodedWithoutNA  naCoded errorGenderBias
#  # 1: 0.97    10  0.1990847          0.02234637 0.180778      0.01117318
#  
#  

## ---- echo=TRUE, eval=TRUE, cache=FALSE----------------------------------
citation('genderizeR')

