import socket

UDP_IP = "127.0.0.1"
UDP_PORT = 24333
MESSAGE = "Hello, World!"

print("UDP target IP:", UDP_IP)
print("UDP target port:", UDP_PORT)
print("message:", MESSAGE)

sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
cnt = 0
while True:
    MESSAGE = "Hello, World! " + str(cnt)
    MESSAGE = MESSAGE.encode()
    cnt += 1
    sock.sendto(MESSAGE, (UDP_IP, UDP_PORT))


# import socket
# import time

# ip = "127.0.0.1"
# port = 24333


# # Create socket for server
# s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, 0)

# # Let's send data through UDP protocol
# cnt = 0
# while True:
#     # send_data = input("Type some text to send =>");
#     cnt += 1
#     send_data = str(cnt)
#     s.sendto(send_data.encode('utf-8'), (ip, port))
#     print(send_data)
#     time.sleep(1)
#     # data, address = s.recvfrom(4096)
#     # print("\n\n 2. Client received : ", data.decode('utf-8'), "\n\n")

# # close the socket
# s.close()