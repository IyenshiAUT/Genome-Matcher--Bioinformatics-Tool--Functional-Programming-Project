{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
#if __GLASGOW_HASKELL__ >= 810
{-# OPTIONS_GHC -Wno-prepositive-qualified-module #-}
#endif
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_genome_matcher (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath




bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "D:\\8th_Semester\\Functional Programming\\Project\\.stack-work\\install\\28275942\\bin"
libdir     = "D:\\8th_Semester\\Functional Programming\\Project\\.stack-work\\install\\28275942\\lib\\x86_64-windows-ghc-9.10.3-b42a\\genome-matcher-0.1.0.0-dOwkPdOjSF789QqUmJ5zA-genome-matcher-exe"
dynlibdir  = "D:\\8th_Semester\\Functional Programming\\Project\\.stack-work\\install\\28275942\\lib\\x86_64-windows-ghc-9.10.3-b42a"
datadir    = "D:\\8th_Semester\\Functional Programming\\Project\\.stack-work\\install\\28275942\\share\\x86_64-windows-ghc-9.10.3-b42a\\genome-matcher-0.1.0.0"
libexecdir = "D:\\8th_Semester\\Functional Programming\\Project\\.stack-work\\install\\28275942\\libexec\\x86_64-windows-ghc-9.10.3-b42a\\genome-matcher-0.1.0.0"
sysconfdir = "D:\\8th_Semester\\Functional Programming\\Project\\.stack-work\\install\\28275942\\etc"

getBinDir     = catchIO (getEnv "genome_matcher_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "genome_matcher_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "genome_matcher_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "genome_matcher_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "genome_matcher_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "genome_matcher_sysconfdir") (\_ -> return sysconfdir)



joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '\\'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/' || c == '\\'
