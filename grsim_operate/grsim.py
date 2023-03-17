import socket
import sys

# import .protos_py.grSim_Packet_pb2 as grSim_Packet_pb2
from .protos_py import grSim_Packet_pb2

class grSimCommunicator:
    def __init__(self, rcv_port = 1060, send_port = 20011):
        host = socket.gethostname()
        address = (host,rcv_port)

        self.rcv_port = rcv_port
        self.send_port = send_port
        self.socket = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
        self.socket.bind(address)
        self.robot_num = 16
        self.width = 12000
        self.height = 9000
        self.robot_info = [] # [[yellow],[blue]] -> [x,y,dir]
        self.ball_info = [] # [x,y,vx,vy]
        self.init_pos()

    def init_pos(self): # out of the field
        blue = []
        yellow = []
        for i in range(self.robot_num):
            blue.append([-self.width/2 + i * 200 ,  -self.height/2-500, 0])
            yellow.append([self.width/2 - i * 200,  -self.height/2-500, 180])
        self.robot_info = [blue, yellow]
        self.ball_info = [0, 0, 0, 0]

    def set_position(self, id, yellowteam, x = 0, y = 0, dir = 0):
        self.robot_info[yellowteam][id] = [x, y, dir]

    def set_robot_info(self, info):
        self.robot_info = info

    def set_ball_info(self, info):
        self.ball_info = info

    def receive(self):
        receiveMsg = self.socket.recvfrom(1024)
        if receiveMsg:
            self.msg.ParseFromString(receiveMsg[0])
        else:
            pass

    def reset(self):
        packet = grSim_Packet_pb2.grSim_Packet()

        for i in range(2):
            for j in range(self.robot_num):
                robot = packet.replacement.robots.add()
                robot.x = self.robot_info[i][j][0] / 1000 # mm -> m
                robot.y = self.robot_info[i][j][1] / 1000
                robot.dir = self.robot_info[i][j][2]
                robot.yellowteam = bool(i)
                robot.id = j

        ball = packet.replacement.ball
        ball.x, ball.y, ball.vx, ball.vy = [x / 1000 for x in self.ball_info]

        self.send(packet)        

    def send(self, sendMsg):
        sendData = sendMsg.SerializeToString()
        self.socket.sendto(sendData, ('', self.send_port))
        # print("send message:")
        # print(sendMsg)

def reset():
    comm = grSimCommunicator()
    comm.set_position(0, 0, 0, 1000)
    comm.set_position(1, 0, 0, 2000)
    comm.set_ball_info([1000, 1000, 0, 0])
    comm.reset()

if __name__ == "__main__":
    reset()