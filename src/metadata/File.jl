struct Footer <: FlatBuffers.Table
    bytes::Vector{UInt8}
    pos::Base.Int
end

function Base.getproperty(x::Footer, field::Symbol)
    if field === :version
        o = FlatBuffers.offset(x, 4)
        o != 0 && return FlatBuffers.get(x, o + x.pos, MetadataVersion)
    elseif field === :schema
        o = FlatBuffers.offset(x, 6)
        if o != 0
            y = FlatBuffers.indirect(x, o + x.pos)
            return FlatBuffers.init(Schema, x.bytes, y)
        end
    elseif field === :dictionaries
        o = FlatBuffers.offset(x, 8)
        if o != 0
            return FlatBuffers.Array{Block}(x, o)
        end
    elseif field === :recordBatches
        o = FlatBuffers.offset(x, 10)
        if o != 0
            return FlatBuffers.Array{Block}(x, o)
        end
    elseif field === :custom_metadata
        o = FlatBuffers.offset(x, 12)
        if o != 0
            return FlatBuffers.Array{KeyValue}(x, o)
        end
    end
    return nothing
end

footerStart(b::FlatBuffers.Builder) = FlatBuffers.startobject!(b, 4)
footerAddVersion(b::FlatBuffers.Builder, version::MetadataVersion) = FlatBuffers.prependslot!(b, 0, version, 0)
footerAddSchema(b::FlatBuffers.Builder, schema::FlatBuffers.UOffsetT) = FlatBuffers.prependoffsetslot!(b, 1, schema, 0)
footerAddDictionaries(b::FlatBuffers.Builder, dictionaries::FlatBuffers.UOffsetT) = FlatBuffers.prependoffsetslot!(b, 2, dictionaries, 0)
footerStartDictionariesVector(b::FlatBuffers.Builder, numelems) = FlatBuffers.startvector!(b, 24, numelems, 8)
footerAddRecordBatches(b::FlatBuffers.Builder, recordbatches::FlatBuffers.UOffsetT) = FlatBuffers.prependoffsetslot!(b, 3, recordbatches, 0)
footerStartRecordBatchesVector(b::FlatBuffers.Builder, numelems) = FlatBuffers.startvector!(b, 24, numelems, 8)
footerEnd(b::FlatBuffers.Builder) = FlatBuffers.endobject!(b)

struct Block <: FlatBuffers.Struct
    bytes::Vector{UInt8}
    pos::Base.Int
end

FlatBuffers.structsizeof(::Base.Type{Block}) = 24

function Base.getproperty(x::Block, field::Symbol)
    if field === :offset
        return FlatBuffers.get(x, x.pos, Int64)
    elseif field === :metaDataLength
        return FlatBuffers.get(x, x.pos + 8, Int32)
    elseif field === :bodyLength
        return FlatBuffers.get(x, x.pos + 16, Int64)
    end
    return nothing
end

function createBlock(b::FlatBuffers.Builder, offset::Int64, metadatalength::Int32, bodylength::Int64)
    FlatBuffers.prep!(b, 8, 24)
    prepend!(b, bodylength)
    FlatBuffers.pad!(b, 4)
    prepend!(b, metadatalength)
    prepend!(b, offset)
    return FlatBuffers.offset(b)
end