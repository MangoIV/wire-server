-- This file is part of the Wire Server implementation.
--
-- Copyright (C) 2022 Wire Swiss GmbH <opensource@wire.com>
--
-- This program is free software: you can redistribute it and/or modify it under
-- the terms of the GNU Affero General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option) any
-- later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
-- details.
--
-- You should have received a copy of the GNU Affero General Public License along
-- with this program. If not, see <https://www.gnu.org/licenses/>.

module Wire.API.MLS.Serialisation
  ( ParseMLS (..),
    parseMLSVector,
    parseMLSBytes,
    parseMLSOptional,
    parseMLSEnum,
    BinaryMLS (..),
    MLSEnumError (..),
    fromMLSEnum,
    toMLSEnum',
    toMLSEnum,
    decodeMLS,
    decodeMLS',
    decodeMLSWith,
    decodeMLSWith',
  )
where

import Control.Applicative
import Data.Binary
import Data.Binary.Get
import qualified Data.ByteString.Lazy as LBS
import qualified Data.Text as T
import Imports

-- | Parse a value encoded using the "TLS presentation" format.
class ParseMLS a where
  parseMLS :: Get a

parseMLSVector :: forall w a. (Binary w, Integral w) => Get a -> Get [a]
parseMLSVector getItem = do
  len <- get @w
  if len == 0
    then pure []
    else isolate (fromIntegral len) $ go (fromIntegral len)
  where
    go :: Int64 -> Get [a]
    go endPos = do
      x <- getItem
      pos <- bytesRead
      (:) <$> pure x <*> if pos < endPos then go endPos else pure []

parseMLSBytes :: forall w. (Binary w, Integral w) => Get ByteString
parseMLSBytes = do
  len <- fromIntegral <$> get @w
  getByteString len

parseMLSOptional :: Get a -> Get (Maybe a)
parseMLSOptional g = do
  b <- getWord8
  sequenceA $ guard (b /= 0) $> g

-- | Parse a positive tag for an enumeration. The value 0 is considered
-- "reserved", and all other values are shifted down by 1 to get the
-- corresponding enumeration index. This makes it possible to parse enumeration
-- types that don't contain an explicit constructor for a "reserved" value.
parseMLSEnum ::
  forall (w :: *) a.
  (Bounded a, Enum a, Integral w, Binary w) =>
  String ->
  Get a
parseMLSEnum name = toMLSEnum name =<< get @w

data MLSEnumError = MLSEnumUnkonwn | MLSEnumInvalid

toMLSEnum' :: forall a w. (Bounded a, Enum a, Integral w) => w -> Either MLSEnumError a
toMLSEnum' w = case fromIntegral w - 1 of
  n
    | n < 0 -> Left MLSEnumInvalid
    | n < fromEnum @a minBound || n > fromEnum @a maxBound -> Left MLSEnumUnkonwn
    | otherwise -> pure (toEnum n)

toMLSEnum :: forall a w f. (Bounded a, Enum a, MonadFail f, Integral w) => String -> w -> f a
toMLSEnum name = either err pure . toMLSEnum'
  where
    err MLSEnumUnkonwn = fail $ "Unknown " <> name
    err MLSEnumInvalid = fail $ "Invalid " <> name

fromMLSEnum :: (Integral w, Enum a) => a -> w
fromMLSEnum = fromIntegral . succ . fromEnum

instance ParseMLS Word8 where parseMLS = get

instance ParseMLS Word16 where parseMLS = get

instance ParseMLS Word32 where parseMLS = get

instance ParseMLS Word64 where parseMLS = get

-- | A wrapper to generate a 'ParseMLS' instance given a 'Binary' instance.
newtype BinaryMLS a = BinaryMLS a

instance Binary a => ParseMLS (BinaryMLS a) where
  parseMLS = BinaryMLS <$> get

-- | Decode an MLS value from a lazy bytestring. Return an error message in case of failure.
decodeMLS :: ParseMLS a => LByteString -> Either Text a
decodeMLS = decodeMLSWith parseMLS

decodeMLS' :: ParseMLS a => ByteString -> Either Text a
decodeMLS' = decodeMLS . LBS.fromStrict

-- | Decode an MLS value from a lazy bytestring given a custom parser.
-- Return an error message in case of failure.
decodeMLSWith :: Get a -> LByteString -> Either Text a
decodeMLSWith p b = case runGetOrFail p b of
  Left (_, _, msg) -> Left (T.pack msg)
  Right (remainder, pos, x)
    | LBS.null remainder -> Right x
    | otherwise -> Left $ "Trailing data at position " <> T.pack (show pos)

decodeMLSWith' :: Get a -> ByteString -> Either Text a
decodeMLSWith' p = decodeMLSWith p . LBS.fromStrict
