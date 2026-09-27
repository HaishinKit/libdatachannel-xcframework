import libdatachannel
var configuration = rtcConfiguration()
let connection = rtcCreatePeerConnection(&configuration)
precondition(connection >= 0)
precondition(rtcDeletePeerConnection(connection) == 0)
rtcCleanup()
print("libdatachannel: Swift import, shared OpenSSL, and peer lifecycle OK")
