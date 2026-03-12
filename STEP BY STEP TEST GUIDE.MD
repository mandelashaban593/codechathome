6️⃣ Run the Receiver

Open terminal:

cd D:\sites\flutter_projects\game_controller_receiver

Activate environment:

gaprecEnv\Scripts\activate

Run:

python ble_receiver.py

You will see:

Scanning for Bluetooth devices...
Found: FlutterGameController XX:XX:XX:XX
Found: Samsung Galaxy XX:XX:XX:XX

This confirms the laptop can see the phone over Bluetooth.

7️⃣ Testing With Your Flutter App

Steps:

1️⃣ Turn Bluetooth ON on phone
2️⃣ Turn Bluetooth ON on laptop
3️⃣ Run the Python BLE script
4️⃣ Open your Flutter controller app
5️⃣ Connect to laptop

Start a game like:

🎮 Asphalt 9: Legends

Then tilt the phone.

Commands received:

LEFT
RIGHT
ACCELERATE

Python converts them to keyboard keys.

Important Reality

On Windows, Python can:

✔ Scan Bluetooth devices
✔ Connect to BLE devices
✔ Receive BLE messages

But it cannot easily host a classic Bluetooth server.

That’s why BLE is the correct method for your project.