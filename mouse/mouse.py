from pynput import mouse

def on_move(x, y):
    print('Pointer moved to {0}'.format(
        (x, y)))

def on_click(x, y, button, pressed):
    print('{0} {1} at {2}'.format(
        button, 
        'Pressed' if pressed else 'Released',
        (x, y)))
    # if not pressed:
        # Stop listener
        # return False

def on_scroll(x, y, dx, dy):
    print('Scrolled {0} at {1}'.format(
        'down' if dy < 0 else 'up',
        (x, y)))

# Collect events until released
# with mouse.Listener(
#         on_move=on_move,
#         on_click=on_click,
#         on_scroll=on_scroll) as listener:
#     listener.join()

# ...or, in a non-blocking fashion:
# listener = mouse.Listener(
#     on_move=on_move,
#     on_click=on_click,
#     on_scroll=on_scroll)

# listener.start()

from pynput.mouse import Button, Controller
mouse = Controller()
from time import sleep
import math


# 尝试实现drag方案


# will be wrong when mouse move
def drag1(start, end, fps, time): # time in second
    frame_num = math.floor(time * fps)
    x, y = start
    dx, dy = (end[0]-start[0])/frame_num, (end[1]-start[1])/frame_num

    # init mouse posiotion
    mouse.move( x-mouse.position[0], y-mouse.position[1])

    mouse.press(Button.left)
    for i in range(frame_num):
        mouse.move(dx, dy)
        sleep(1/fps)
    mouse.release(Button.left)

def move_to(position):
    mouse.move( position[0]-mouse.position[0], position[1]-mouse.position[1])

def drag2(start, end, fps, time): # time in second
    frame_num = math.floor(time * fps)
    x, y = start
    dx, dy = (end[0]-start[0])/frame_num, (end[1]-start[1])/frame_num

    # init mouse posiotion
    move_to(start)

    mouse.press(Button.left)
    for i in range(frame_num):
        x += dx
        y += dy
        move_to([x, y])
        sleep(1/fps)
    mouse.release(Button.left)


drag2((342, 170), (1396, 781), 100, 5)