module Paths_speaking_parts (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch


version :: Version
version = Version {versionBranch = [0,1,0,0], versionTags = []}
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/err8n/p/speaking-parts/.cabal-sandbox/bin"
libdir     = "/Users/err8n/p/speaking-parts/.cabal-sandbox/lib/x86_64-osx-ghc-7.6.3/speaking-parts-0.1.0.0"
datadir    = "/Users/err8n/p/speaking-parts/.cabal-sandbox/share/x86_64-osx-ghc-7.6.3/speaking-parts-0.1.0.0"
libexecdir = "/Users/err8n/p/speaking-parts/.cabal-sandbox/libexec"
sysconfdir = "/Users/err8n/p/speaking-parts/.cabal-sandbox/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "speaking_parts_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "speaking_parts_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "speaking_parts_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "speaking_parts_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "speaking_parts_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
