#include <libdatachannel/rtc/rtc.h>
#include <openssl/crypto.h>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <mutex>

static std::atomic<bool> received(false), failed(false);
static std::condition_variable changed;
static std::mutex mutex;
static const char payload[] = "libdatachannel with shared OpenSSL DTLS/SCTP";
static void check(int result) {
    if (result < 0) { failed = true; changed.notify_all(); }
}
static void description(int, const char* sdp, const char* type, void* remote) {
    int pc = *static_cast<int*>(remote);
    check(rtcSetRemoteDescription(pc, sdp, type));
    if (std::strcmp(type, "offer") == 0) check(rtcSetLocalDescription(pc, "answer"));
}
static void candidate(int, const char* value, const char* mid, void* remote) {
    check(rtcAddRemoteCandidate(*static_cast<int*>(remote), value, mid));
}
static void message(int, const char* data, int size, void*) {
    if (size == sizeof(payload) - 1 && std::memcmp(data, payload, size) == 0) received = true;
    else failed = true;
    changed.notify_all();
}
static void channel(int, int dc, void*) { check(rtcSetMessageCallback(dc, message)); }
static void opened(int dc, void*) { check(rtcSendMessage(dc, payload, sizeof(payload) - 1)); }
int main(int argc, char** argv) {
    const char* expected = argc > 1 ? argv[1] : "3.3.3";
    if (std::strcmp(OpenSSL_version(OPENSSL_VERSION_STRING), expected)) return 2;
    rtcConfiguration config = {};
    config.disableAutoNegotiation = true;
    int a = rtcCreatePeerConnection(&config), b = rtcCreatePeerConnection(&config);
    if (a < 0 || b < 0) return 3;
    rtcSetUserPointer(a, &b); rtcSetUserPointer(b, &a);
    check(rtcSetLocalDescriptionCallback(a, description));
    check(rtcSetLocalDescriptionCallback(b, description));
    check(rtcSetLocalCandidateCallback(a, candidate));
    check(rtcSetLocalCandidateCallback(b, candidate));
    check(rtcSetDataChannelCallback(b, channel));
    int dc = rtcCreateDataChannel(a, "loopback");
    check(dc); check(rtcSetOpenCallback(dc, opened));
    check(rtcSetLocalDescription(a, "offer"));
    {
        std::unique_lock<std::mutex> lock(mutex);
        changed.wait_for(lock, std::chrono::seconds(20), [] { return received || failed; });
    }
    bool success = received && !failed;
    rtcDeletePeerConnection(a); rtcDeletePeerConnection(b); rtcCleanup();
    if (!success) { std::fprintf(stderr, "DTLS/SCTP loopback failed or timed out\n"); return 1; }
    std::printf("libdatachannel / OpenSSL %s: DTLS/SCTP message passed\n", expected);
}
