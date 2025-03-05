import serial
import time

PORT = 'COM3'          # Replace with your actual COM port
BAUD_RATE = 9600       # Ensure this matches your settings

try:
    ser = serial.Serial(PORT, BAUD_RATE, timeout=1)
    time.sleep(2)  # Allow time for initialization

    # Send a test message
    test_message = "Hello, HW417!\n"
    ser.write(test_message.encode())
    print(f"Sent: {test_message.strip()}")

    # Read and print the response (if any)
    response = ser.readline().decode().strip()
    if response:
        print(f"Received: {response}")
    else:
        print("No response received.")

    # Keep the port open for a bit to view it in PuTTY
    time.sleep(5)

except serial.SerialException as e:
    print(f"Serial error: {e}")
except Exception as e:
    print(f"Error: {e}")
finally:
    if ser:
        ser.close()
