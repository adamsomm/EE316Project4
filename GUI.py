import serial
import time
import threading
import tkinter as tk
import random

# Tkinter Window Setup
root = tk.Tk()
root.title("Hangman Game")

# Serial Communication Setup
PORT = 'COM3'  # Change to your actual COM port
BAUD_RATE = 9600

try:
    ser = serial.Serial(PORT, BAUD_RATE, timeout=1)
    time.sleep(2)  # Allow time for initialization
except serial.SerialException as e:
    ser = None
    print(f"Serial error: {e}")

def send_guess_to_serial(guess):
    """Send the guessed letter over the serial port in a separate thread."""
    if ser:
        threading.Thread(target=lambda: ser.write((guess + "\n").encode()), daemon=True).start()

# List of words for Hangman
word_list = ["PYTHON", "TKINTER", "HANGMAN", "COMPUTER", "ENGINEER"]
secret_word = random.choice(word_list)  # Choose a word randomly
guessed_letters = set()
max_attempts = 6
attempts_left = max_attempts
puzzles_solved = 0
puzzles_attempted = 0

# Load images (Ensure images named '0.png' to '6.png' exist in the same directory)
images = [tk.PhotoImage(file=f"{i}.png") for i in range(6)]

def update_display():
    display_word = " ".join([letter if letter in guessed_letters else "_" for letter in secret_word])
    word_label.config(text=display_word)
    attempts_label.config(text=f"Attempts Left: {attempts_left}")

    # Ensure image index stays within bounds
    image_index = min(max_attempts - attempts_left, len(images) - 1)
    image_label.config(image=images[image_index])

def check_guess(event=None):
    global attempts_left, puzzles_solved, puzzles_attempted
    guess = entry.get().upper()
    entry.delete(0, tk.END)

    if not guess.isalpha() or len(guess) != 1:
        message_label.config(text="Enter a single valid letter.", fg="red")
        return

    if guess in guessed_letters:
        message_label.config(text="You already guessed that letter.", fg="orange")
        return

    guessed_letters.add(guess)
    send_guess_to_serial(guess) # sends to FPGA

    used_label.config(text=f"used letters: {guessed_letters} \n", fg="black")
    if guess not in secret_word:
        attempts_left -= 1

    update_display()

    if set(secret_word) <= guessed_letters:
        puzzles_solved += 1
        puzzles_attempted += 1
        message_label.config(text="🎉 Well done!", fg="green")
        score_label.config(text=f"You have solved {puzzles_solved} out of {puzzles_attempted}")
        end_game()
    elif attempts_left == 0:
        puzzles_attempted += 1
        message_label.config(text=f"Sorry! The correct word was {secret_word}", fg="red")
        score_label.config(text=f"You have solved {puzzles_solved} out of {puzzles_attempted}")
        end_game()

def end_game():
    entry.config(state=tk.DISABLED)
    guess_button.config(state=tk.DISABLED)
    prompt_for_new_game()

def prompt_for_new_game():
    new_game_label.config(text="New Game? (Y/N)")
    entry.config(state=tk.NORMAL)
    entry.bind("<Return>", handle_new_game_response)

def handle_new_game_response(event=None):
    global secret_word, guessed_letters, attempts_left
    response = entry.get().upper()
    entry.delete(0, tk.END)
    if response == "Y":
        secret_word = random.choice(word_list)
        guessed_letters.clear()
        attempts_left = max_attempts
        entry.config(state=tk.NORMAL)
        guess_button.config(state=tk.NORMAL)
        message_label.config(text="")
        score_label.config(text="")
        new_game_label.config(text="")
        update_display()
    elif response == "N":
        message_label.config(text=f"GAME OVER", fg="blue")
        new_game_label.config(text=f"Final Score: {puzzles_solved} correct out of {puzzles_attempted}")
        entry.config(state=tk.DISABLED)

def start_game():
    entry.bind("<Return>", check_guess)
    update_display()
    threading.Thread(target=receive_data_from_serial, daemon=True).start()  # Start listening for serial data


def receive_data_from_serial():
    """Continuously read data from the serial port in a separate thread."""
    while True:
        if ser:
            try:
                data = ser.readline().decode().strip()  # Read and decode data
                if data:
                    root.after(0, process_serial_data, data)  # Schedule UI update in main thread
            except Exception as e:
                print(f"Serial read error: {e}")

def process_serial_data(data):
    """Process received serial data and update the UI."""
    global attempts_left
    message_label.config(text=f"Received: {data}", fg="blue")

    if data.startswith("CORRECT"):  # Example hardware response
        message_label.config(text="Hardware: Correct Guess!", fg="green")
    elif data.startswith("WRONG"):  # Example hardware response
        attempts_left -= 1
        update_display()
        message_label.config(text="Hardware: Incorrect Guess!", fg="red")

# UI Elements
image_label = tk.Label(root, image=images[0])
image_label.pack()

word_label = tk.Label(root, text="_ " * len(secret_word), font=("Arial", 24))
word_label.pack(pady=10)

attempts_label = tk.Label(root, text=f"Attempts Left: {attempts_left}", font=("Arial", 14))
attempts_label.pack()

entry = tk.Entry(root, font=("Arial", 14))
entry.pack(pady=5)

guess_button = tk.Button(root, text="Guess", command=check_guess)
guess_button.pack(pady=5)

used_label = tk.Label(root, text="Used Letters: ", font=("Arial", 14))
used_label.pack()

message_label = tk.Label(root, text="", font=("Arial", 12))
message_label.pack()

score_label = tk.Label(root, text="", font=("Arial", 12))  # Separate label for score tracking
score_label.pack()

new_game_label = tk.Label(root, text="", font=("Arial", 12))  # Label for "New Game? (Y/N)"
new_game_label.pack()

# Initialize display
start_game()

root.mainloop()

if ser:
    ser.close()