// swift_kept_ref_runme.swift — pin a constructor argument for the wrapping
// object's lifetime via the swiftcode + swiftconstruct typemaps (ARC).

func makeAdapter() throws -> Adapter {
    let codec = try Codec(i: 5)          // Swift proxy owns the C++ Codec
    return try Adapter(codec: codec)     // Adapter pins codec via keptCodec
    // 'codec' local drops here; without the pin ARC would free the C++ Codec.
}

let liveStart = try codec_live_count()
assert(liveStart == 0)

var adapter: Adapter? = try makeAdapter()
// The pinned codec is still alive even though the local reference is gone; a
// non-pinning adapter would have let ARC free it (count would be 0 here).
let livePinned = try codec_live_count()
assert(livePinned == 1)
let id = try adapter!.codecId()
assert(id == 5)

adapter = nil                            // releases the pin -> Codec freed
let liveEnd = try codec_live_count()
assert(liveEnd == 0)
