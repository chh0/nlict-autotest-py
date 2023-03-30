#include <iostream>
#include <string.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

int main() {
    int sockfd;
    char buffer[1024];
    struct sockaddr_in servaddr;

    // Create a UDP socket
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);

    // Set up the server address and port
    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(24333);
    servaddr.sin_addr.s_addr = inet_addr("127.0.0.1");

    while (true) {
        // Send a message to the server
        std::string message = "Hello, world!";
        strcpy(buffer, message.c_str());
        sendto(sockfd, buffer, strlen(buffer), 0, (const struct sockaddr*) &servaddr, sizeof(servaddr));
        std::cout << "Sent message: " << message << std::endl;
        sleep(1);
    }

    return 0;
}
