from pynput.mouse import Button, Controller
import time
import pickle

mouse = Controller()

file_name = "Sun Mar  5 23:12:25 2023"

'''
[
    [time, event, position],
    [time, event, position],
    [time, event, position],
    ......
]
time: float, like 1677833315.70825
event: string, e.g.
        'MOVE'
        'PRESS_LEFT'
        'PRESS_RIGHT'
        'RELEASE_LEFT'
        'RELEASE_RIGHT'
        'SCROLL_UP'
        'SCROLL_DOWN'
        
position: (x, y)
'''

def move_to(position):
    mouse.move( position[0]-mouse.position[0], position[1]-mouse.position[1])

def play_frame(frame):
    if frame[1] == 'MOVE':
        move_to(frame[2])
    elif frame[1] == 'PRESS_LEFT':
        move_to(frame[2])
        mouse.press(Button.left)
    elif frame[1] == 'PRESS_RIGHT':
        move_to(frame[2])
        mouse.press(Button.right)
    elif frame[1] == 'RELEASE_LEFT':
        move_to(frame[2])
        mouse.release(Button.left)
    elif frame[1] == 'RELEASE_RIGHT':
        move_to(frame[2])
        mouse.release(Button.right)
    elif frame[1] == 'SCROLL_UP':
        move_to(frame[2])
        mouse.scroll(0, 1)
    elif frame[1] == 'SCROLL_DOWN':
        move_to(frame[2])
        mouse.scroll(0, -1)


def play_record(record):
    begin_time = record[0][0]
    play_frame(record[0])
    for i in range(len(record)-1):
        time.sleep(record[i+1][0]-record[i][0])
        play_frame(record[i+1])


with open("LOG/" + file_name, "rb") as f:
    record = pickle.load(f)

play_record(record)