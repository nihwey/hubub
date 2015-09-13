# Description:
#   Hubub's language model

# -- This is the list of phrases that Hubub listens to.
triggers = [
  '[Hh]ello',
  '[Hh]ey',
  '[Hh]i',
  '[Hh]ow',
  'idea',
  '[Ss]ay',
  'speak',
  'talk',
  'think',
  '[Ww]hat',
  '[Ww]hy'
]

# -- Language generation

consonants = 'bcdfghjklmnpqrstvwxzbcdghklmnprstvw'
vowels = 'aeiouyaeiou'
alphabet = vowels + vowels + consonants + vowels

specialWords = [
  'chocolate',
  'hehe',
  'laa~',
  'rice',
  'sushi',
  '<3',
  '>.>'
]

punctuation = [
  '.', '.',
  '...',
  '?',
  '!',
  '!!'
]

at = (name) ->
  '@' + name

# Generates a random integer between the given bounds.
#   {number} min Lower bound integer, inclusive.
#   {number} max Upper bound integer, exclusive.
randInt = (min, max) ->
  Math.floor(Math.random() * (max - min)) + min

# Picks a single item from the given list of options.
#   {Array} options A list of options.
pickOne = (options) ->
  options[randInt(0, options.length)]

# Picks a single item from the given list of options and remove it from the
# list of options.
#   {Array} options A list of options.
pickOneAndRemove = (options) ->
  i = randInt(0, options.length)
  chosen = options[i]
  options[i] = []
  chosen

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
  specialWordsCopy = specialWords[..]
  phrase = while length -= 1
    if Math.round(Math.random() * 8) is 2 and specialWordsCopy.length > 0
      pickOneAndRemove(specialWordsCopy)
    else
      generateWord(randInt(1, 7))
  phrase = phrase.join(' ')
  at(userName) + ' ' + phrase + pickOne(punctuation)


# -- Response handling

module.exports = (robot) ->
  # Respond to any of the triggers with a random phrase.
  robot.hear new RegExp(triggers.join('|')), (res) ->
    numWords = randInt(1, 10)
    res.send generatePhrase(numWords, res.envelope.user.name)
