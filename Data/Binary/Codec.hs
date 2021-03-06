module Data.Binary.Codec
  (
  -- * Binary codecs
    BinaryCodec
  , byteString
  , toLazyByteString
  , word8
  , word16be, word16le, word16host
  , word32be, word32le, word32host
  , word64be, word64le, word64host
  , wordhost
  )
 where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as LBS
import Data.Binary.Get
import Data.Binary.Put
import Data.Word

import Data.Codec.Codec

type BinaryCodec a = Codec Get PutM a

-- | Get/put an n-byte field.
byteString :: Int -> BinaryCodec BS.ByteString
byteString n = Codec
  { parse = getByteString n
  , produce = \bs -> if BS.length bs == n
      then putByteString bs
      else fail "ByteString wrong size for field."
  }

word8 :: BinaryCodec Word8
word8 = Codec getWord8 putWord8

word16be :: BinaryCodec Word16
word16be = Codec getWord16be putWord16be

word16le :: BinaryCodec Word16
word16le = Codec getWord16le putWord16le

word16host :: BinaryCodec Word16
word16host = Codec getWord16host putWord16host

word32be :: BinaryCodec Word32
word32be = Codec getWord32be putWord32be

word32le :: BinaryCodec Word32
word32le = Codec getWord32le putWord32le

word32host :: BinaryCodec Word32
word32host = Codec getWord32host putWord32host

word64be :: BinaryCodec Word64
word64be = Codec getWord64be putWord64be

word64le :: BinaryCodec Word64
word64le = Codec getWord64le putWord64le

word64host :: BinaryCodec Word64
word64host = Codec getWord64host putWord64host

wordhost :: BinaryCodec Word
wordhost = Codec getWordhost putWordhost

-- | Convert a `BinaryCodec` into a `ConcreteCodec` on lazy `LBS.ByteString`s.
toLazyByteString :: BinaryCodec a -> ConcreteCodec LBS.ByteString (Either String) a
toLazyByteString (Codec r w) = concrete
  (\bs -> case runGetOrFail r bs of
    Left ( _ , _, err ) -> Left err
    Right ( _, _, x ) -> Right x)
  (runPut . w)
