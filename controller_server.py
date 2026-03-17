import asyncio
import websockets
import pyautogui

PORT = 5000

async def handler(websocket):

    print("Controller connected")

    async for message in websocket:

        cmd = message.strip()

        print("Command:", cmd)

        if cmd == "UP":
            pyautogui.press("up")

        elif cmd == "DOWN":
            pyautogui.press("down")

        elif cmd == "LEFT":
            pyautogui.press("left")

        elif cmd == "RIGHT":
            pyautogui.press("right")

        elif cmd == "OK":
            pyautogui.press("enter")

        elif cmd.isdigit():
            pyautogui.press(cmd)

async def main():

    print("Starting controller server on port", PORT)

    async with websockets.serve(handler, "0.0.0.0", PORT):

        await asyncio.Future()

asyncio.run(main())