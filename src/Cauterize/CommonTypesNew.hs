{-# LANGUAGE OverloadedStrings #-}
module Cauterize.CommonTypesNew
  ( Offset
  , Length
  , Identifier
    , unIdentifier
    , unsafeMkIdentifier
    , mkIdentifier
  , Prim(..)
    , allPrims
    , allPrimNames
    , primToText
    , primToSize
  , Tag(..)
    , tagToText
    , tagToSize
  , Size
    , sizeMin
    , sizeMax
    , mkSize
    , mkConstSize
  ) where

import Data.String
import Data.Word
import Data.Int
import Data.Char
import Data.Text (Text, pack, empty)
import Data.Maybe

type Offset = Int64

type Length = Word64

newtype Identifier = Identifier { unIdentifier :: Text }
  deriving (Eq, Ord)

data Prim
  = PU8
  | PU16
  | PU32
  | PU64
  | PS8
  | PS16
  | PS32
  | PS64
  | PF32
  | PF64
  | PBool
  deriving (Show, Eq, Enum, Bounded)

data Tag = T1 | T2 | T4 | T8
  deriving (Show, Eq)

data Size = Size { sizeMin :: Integer, sizeMax :: Integer }

isValidIdentifier :: String -> Bool
isValidIdentifier [] = False
isValidIdentifier (s:r) = first && rest
  where
    first = isAsciiLower s
    rest = all (\c -> isAsciiLower c || isDigit c || ('_' == c)) r

unsafeMkIdentifier :: String -> Identifier
unsafeMkIdentifier s =
  fromMaybe
    (error $ "unsafeMkIdentifier: invalid input string \"" ++ s ++ "\"")
    (mkIdentifier s)

mkIdentifier :: String -> Maybe Identifier
mkIdentifier [] = Just (Identifier empty)
mkIdentifier i =
    if isValidIdentifier i
      then Just (Identifier $ pack i)
      else Nothing

mkSize :: Integer -> Integer -> Size
mkSize rmin rmax | rmin < 1 = error ("Min size less than 1: " ++ show rmin)
                 | rmax < 1 = error ("Max size less than 1: " ++ show rmax)
                 | rmin <= rmax = Size rmin rmax
                 | otherwise = error ("Bad min and max: min " ++ show rmin ++ " >= max " ++ show rmax ++ ".")

mkConstSize :: Integer -> Size
mkConstSize sz = mkSize sz sz

primToText :: Prim -> Identifier
primToText PU8    = "u8"
primToText PU16   = "u16"
primToText PU32   = "u32"
primToText PU64   = "u64"
primToText PS8    = "s8"
primToText PS16   = "s16"
primToText PS32   = "s32"
primToText PS64   = "s64"
primToText PF32   = "f32"
primToText PF64   = "f64"
primToText PBool  = "bool"

allPrims :: [Prim]
allPrims = [minBound..maxBound]

allPrimNames :: [Identifier]
allPrimNames = map primToText allPrims

primToSize :: Prim -> Size
primToSize PU8    = mkConstSize 1
primToSize PU16   = mkConstSize 2
primToSize PU32   = mkConstSize 4
primToSize PU64   = mkConstSize 8
primToSize PS8    = mkConstSize 1
primToSize PS16   = mkConstSize 2
primToSize PS32   = mkConstSize 4
primToSize PS64   = mkConstSize 8
primToSize PF32   = mkConstSize 4
primToSize PF64   = mkConstSize 8
primToSize PBool  = mkConstSize 1

tagToText :: Tag -> Identifier
tagToText T1 = "t1"
tagToText T2 = "t2"
tagToText T4 = "t4"
tagToText T8 = "t8"

tagToSize :: Tag -> Size
tagToSize T1 = mkConstSize 1
tagToSize T2 = mkConstSize 2
tagToSize T4 = mkConstSize 4
tagToSize T8 = mkConstSize 8

instance IsString Identifier where
  fromString s =
    fromMaybe
      (error $ "IsString Identifier: invalid input string \"" ++ s ++ "\"")
      (mkIdentifier s)

instance Show Identifier where
  show (Identifier i) = "i" ++ show i

instance Show Size where
  show (Size smin smax) | smin == smax = "Size " ++ show smax
                        | otherwise = "Size " ++ show smin ++ ".." ++ show smax
