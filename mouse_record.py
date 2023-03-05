from pynput import mouse
import time
import pickle

# record mouse movement
RECORD_FILE = []
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


def on_move(x, y):
    print('Pointer moved to {0}'.format(
        (x, y)))
    RECORD_FILE.append([time.time(), "MOVE", (x, y)])

def on_click(x, y, button, pressed):
    print('{0} {1} at {2}'.format(
        str(button)[7:7+6], 
        'Pressed' if pressed else 'Released',
        (x, y)))
    if str(button)[7:7+6] == 'middle':
        print(RECORD_FILE)
        with open('./LOG/'+str(time.ctime()), "wb") as f:
            pickle.dump(RECORD_FILE, f)
        return False
    
    if pressed:
        if str(button)[7:7+6] == 'left':
            event = 'PRESS_LEFT'
        else:
            event = 'RELEASE_LEFT'
    else:
        if str(button)[7:7+6] == 'right':
            event = 'PRESS_RIGHT'
        else:
            event = 'RELEASE_RIGHT'
    RECORD_FILE.append([time.time(), event, (x, y)])

def on_scroll(x, y, dx, dy):
    print('Scrolled {0} at {1}'.format(
        'down' if dy < 0 else 'up',
        (x, y)))
    RECORD_FILE.append([time.time(), 'SCROLL_DOWN' if dy < 0 else 'SCROLL_UP', (x, y)])

# Collect events until released

with mouse.Listener(
        on_move=on_move,
        on_click=on_click,
        on_scroll=on_scroll) as listener:
    listener.join()

# ...or, in a non-blocking fashion:
# listener = mouse.Listener(
#     on_move=on_move,
#     on_click=on_click,
#     on_scroll=on_scroll)
