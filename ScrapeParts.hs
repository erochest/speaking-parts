{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# OPTIONS_GHC -Wall #-}


module Main where


import           Control.Applicative
import           Control.Lens
import           Data.Aeson
import qualified Data.Aeson                   as A
import qualified Data.ByteString.Lazy         as LBS
import qualified Data.ByteString.Lazy.Char8   as C8
import           Data.Conduit
import           Data.Maybe
import qualified Data.Text                    as T
import           Network.HTTP.Conduit
import           Network.HTTP.Conduit.Browser
import           Text.HTML.DOM
import           Text.XML                     hiding (parseLBS)
import           Text.XML.Lens


-- Types

data Hole = Hole

data Part = Part
          { _partId      :: T.Text
          , _partAvatar  :: T.Text
          , _partName    :: T.Text
          , _partByline  :: Maybe T.Text
          , _partTwitter :: Maybe T.Text
          , _partBio     :: T.Text
          } deriving (Show)

makeLenses ''Part

instance ToJSON Part where
    toJSON Part{..} = object [ "id"      A..= _partId
                             , "avatar"  A..= _partAvatar
                             , "name"    A..= _partName
                             , "byline"  A..= _partByline
                             , "twitter" A..= _partTwitter
                             , "bio"     A..= _partBio
                             ]

-- Download

url :: IO (Request m)
url = parseUrl "http://codespeak.scholarslab.org/"

download :: Request (ResourceT IO) -> IO LBS.ByteString
download req = responseBody <$> (runRequestWith =<< newManager def)
    where runRequestWith man = runResourceT $ browse man $ makeRequestLbs req

-- Scraping

scrapeParts :: Document -> [Part]
scrapeParts = catMaybes . map liToPart . (^.. root
                                         .    entire
                                         .    el "ul"
                                         .    attributeIs "class" "participants"
                                         .    entire
                                         .    el "li"
                                         )

liToPart :: Element -> Maybe Part
liToPart elm = part (elm ^? entire . el "p" . attributeIs "class" "byline" . text)
                    (elm ^? entire . el "p" . attributeIs "class" "twitter-handle" . el "a" . text)
             <$>    (elm ^? attr "id")
             <*>    (elm ^? entire . el "img" . attr "src")
             <*>    (elm ^? entire . el "h2" . text)
             <*>    (elm ^? entire . el "p" . attributeIs "class" "bio" . text)
    where part b t i a n d = Part i a n b t d


main :: IO ()
main =
    C8.putStrLn . encode . scrapeParts . parseLBS =<< download =<< url

