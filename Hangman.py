class Hangman:
    winCount = 0
    loseCount = 0

    def __init__(self, word):
        self.word = word.lower()
        self.guessed = ['_' for _ in word]
        for i, char in enumerate(self.word):
                if char == " ":
                    self.guessed[i] = " "
        self.letterBank = []
        self.remainingGuesses = 8
        self.is_game_over = False
        self.outcome = False

    def guess_letter(self, letter):
        letter = letter.lower()
        if self.is_game_over:
            print('This game has ended.')
            print('You Won!' if self.outcome else 'You Lost.')
            return

        # Check if the letter has already been guessed
        if letter in self.letterBank:
            print('Hah dummy, you already guessed that!')
            self.remainingGuesses -= 1
            self.display()
            if self.remainingGuesses == 0:
                Hangman.loseCount += 1
                self.is_game_over = True
                print('You Lose.')
            return  
        
        # Add the guessed letter to the bank
        self.letterBank.append(letter)
        
        if letter in self.word:
            # Reveal the guessed letter in the word
            for i, char in enumerate(self.word):
                if char == letter:
                    self.guessed[i] = letter
            self.display()
            if "_" not in self.guessed:
                Hangman.winCount += 1
                self.outcome = True
                self.is_game_over = True
                #print('You win!')
        else:
            # Decrease remaining guesses on wrong guess
            self.remainingGuesses -= 1
            self.display()
            if self.remainingGuesses == 0:
                Hangman.loseCount += 1
                self.is_game_over = True
                #print('You Lose.')

    def display(self):
        print(f"You have {self.remainingGuesses} guesses left")
        print(f"You have guessed {', '.join(self.letterBank)}")
        print(f"Word: {' '.join(self.guessed)}")

def generateWord():
    import random
    global usedWords
    with open("words.txt") as file:
        allWords = [line.strip() for line in file.readlines()]  # Read all words and remove newline characters
        unusedWords = [w for w in allWords if w not in usedWords]  # Filter out used words

        if not unusedWords:
            userChoice = input("You have used all the words in the list. Press N to exit.").lower()
            if userChoice == 'n':
                return False
            else:
                return generateWord()
        else:
            selectedWord = random.choice(unusedWords)  # Pick a random unused word
            #print(f"{selectedWord} was selected")
            usedWords.append(selectedWord)  # Mark as used
            return selectedWord


usedWords = []
if __name__ == "__main__":
    repeat = True
    print("Welcome to Hangman!")
    while repeat:
        userRepeat = input("New Game?").lower()
        if userRepeat == 'y':
            word = generateWord()
            if word:
                game = Hangman(word)

                while not game.is_game_over:
                    letter = input("Guess a letter: ").lower()  # Get a letter guess from usery
                    game.guess_letter(letter)

                if game.outcome:
                    print('Well Done!')
                else:
                    print(f'Sorry! The correct word was {''.join(game.word)}')
                print(f"You have solved {Hangman.winCount} out of {Hangman.winCount + Hangman.loseCount} games.")

            else:
                repeat = False
                break
        else:
            if userRepeat == 'n':
                break
    print("GAME OVER")
        
