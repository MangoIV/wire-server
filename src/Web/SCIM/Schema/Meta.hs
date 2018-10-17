
module Web.SCIM.Schema.Meta where

import Prelude hiding (map)

import Data.Text (Text, unpack, pack)
import qualified Data.Text as Text
import Text.Read (readEither)
import Data.Monoid ((<>))
import Data.Aeson
import Web.SCIM.Schema.Common
import Web.SCIM.Schema.ResourceType
import GHC.Generics (Generic)
import qualified Data.HashMap.Lazy as HML
import Data.Time.Clock

data ETag = Weak Text | Strong Text
  deriving (Eq, Show)

instance ToJSON ETag where
  toJSON (Weak tag) = String $ "W/" <> pack (show tag)
  toJSON (Strong tag) = String $ pack (show tag)

instance FromJSON ETag where
  parseJSON = withText "ETag" $ \s ->
    case Text.stripPrefix "W/" s of
      Nothing -> Strong <$> unquote s
      Just s' -> Weak <$> unquote s'
    where
      unquote s = case readEither (unpack s) of
        Right x -> pure x
        Left e -> fail ("couldn't unquote the string: " <> e)

data Meta = Meta
  { resourceType :: ResourceType
  , created :: UTCTime
  , lastModified :: UTCTime
  , version :: ETag
  , location :: URI
  } deriving (Eq, Show, Generic)

instance ToJSON Meta where
  toJSON = genericToJSON serializeOptions

instance FromJSON Meta where
  parseJSON = genericParseJSON parseOptions . jsonLower

data WithMeta a = WithMeta
  { meta :: Meta
  , thing :: a
  } deriving (Eq, Show, Generic)

instance (ToJSON a) => ToJSON (WithMeta a) where
  toJSON (WithMeta m v) = case toJSON v of
    (Object o) -> Object (HML.insert "meta" (toJSON m) o)
    other      -> other

instance (FromJSON a) => FromJSON (WithMeta a) where
  parseJSON = withObject "WithMeta" $ \o ->
    WithMeta <$> o .: "meta" <*> parseJSON (Object o)
