# T{D}Debug
Project that generates two binaries, one for iOS and one for macOS. Each binary acts as a debug message sink for anything other process that sends data to it.


# Handshaking
The process for one peer to become the client of another is done by sending a series of messages to each other. This handshaking consists of the following flow:

#Connecting
Client Peer                                 Host Peer
Sends Handshake.RequestConnection
                                            Returns:
                                                A) Handshake.ConnectionGranted on success
                                                B) Handshake.ConnectionRefused if no connections possible
If received:
    A) Handshake.ConnectionGranted,
       puts client peer into connected state
    B) Handshake.ConnectionRefused,
       puts client peer into disconnected state

#Disconnecting
Client Peer                                 Host Peer
Sends Handshake.ConnectionClose              
                                             Sets its state to disconnected
                                             Returns Handshake.Disconnected
Sets client peer state to disconnected


Client Peer                                  Host Peer
                                             Asynchronously sends Handshake.DropAsClient
                                             Sets internal state to disconnected
Sets client peer state to disconnected