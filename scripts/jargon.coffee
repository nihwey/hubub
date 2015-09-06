# Description:
#   Hubub's language model


# -- This is the list of phrases that Hubub listens to.
triggers = [
  'hey',
  'how',
  'idea',
  'say',
  'speak',
  'think',
  'what',
  'why'
]


# -- Language generation


consonants = 'bcdfghjklmnpqrstvwxzbcdghklmnprstvw';
vowels = 'aeiouyaeiou'
alphabet = vowels + vowels + consonants + vowels

punctuation = [
  '.', '.',
  '...',
  '?',
  '!',
  '!!'
]


# Generates a random integer between the given bounds.
#   {number} min Lower bound integer, inclusive.
#   {number} max Upper bound integer, exclusive.
randInt = (min, max) ->
  Math.floor(Math.random() * (max - min)) + min


# Picks a single item from the given list of options.
#   {Array} options A list of options.
pickOne = (options) ->
  options[randInt(0, options.length)]


# Generates a single word.
#   {number} length The length of the word to generate.
generateWord = (length) ->
  switch length
    when 1
      word = pickOne(vowels)
    when 2
      if Math.round(Math.random()) is 1
        word = pickOne(vowels) + pickOne(consonants)
      else
        word = pickOne(consonants) + pickOne(vowels)
    else
      word = (pickOne(alphabet) for num in [length..1]).join('')
  word


# Generates a phrase.
#   {number} length The length of the phrase to generate.
#   {string} userName The name of the user who sent the message Hubub
#       is responding to.
generatePhrase = (length, userName) ->
  phrase = (generateWord(randInt(1, 7)) for num in [length..1]).join(' ')
  userName + ' ' + phrase + pickOne(punctuation)


module.exports = (robot) ->
  robot.hear new RegExp(triggers.join('|')), (res) ->
    numWords = randInt(1, 5)
    res.send generatePhrase(numWords, res.envelope.user.name)
