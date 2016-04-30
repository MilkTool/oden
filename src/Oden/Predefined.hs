module Oden.Predefined (
  universe,
  typeInt,
  typeString,
  typeBool,
  typeUnit
) where

import           Oden.Core.Definition
import           Oden.Core.Package
import           Oden.Core.Typed
import           Oden.Identifier
import           Oden.Metadata
import           Oden.QualifiedName
import           Oden.SourceInfo
import           Oden.Type.Polymorphic

import           Data.Set              hiding (map)

predefined :: Metadata SourceInfo
predefined = Metadata Predefined

typeInt, typeString, typeBool, typeUnit :: Type
typeInt = TCon predefined (nameInUniverse "int")
typeString = TCon predefined (nameInUniverse "string")
typeBool = TCon predefined (nameInUniverse "bool")
typeUnit = TCon predefined (nameInUniverse "unit")

protocols :: [(String, Protocol)]
protocols = [
  ("error",
   Protocol predefined (nameInUniverse "error") (TVar predefined (TV "a")) [
     ProtocolMethod predefined (Identifier "Error") (Forall predefined [] empty (TFn predefined (TVar predefined (TV "a")) typeString))
   ])
  ]

foreignFns :: [(Identifier, Scheme)]
foreignFns = [
  (Identifier "len", Forall predefined [TVarBinding predefined (TV "a")] empty (TForeignFn predefined False [TSlice predefined (TVar predefined (TV "a"))] [typeInt])),
  (Identifier "print", Forall predefined [TVarBinding predefined (TV "a")] empty (TForeignFn predefined False [TVar predefined (TV "a")] [typeUnit])),
  (Identifier "println", Forall predefined [TVarBinding predefined (TV "a")] empty (TForeignFn predefined False [TVar predefined (TV "a")] [typeUnit]))
  ]

types :: [(String, Type)]
types = [
  ("int", typeInt),
  ("string", typeString),
  ("bool", typeBool),
  ("unit", typeUnit)
  ]

universe :: TypedPackage
universe =
  TypedPackage
  (PackageDeclaration (Metadata Missing) [])
  []
  (concat [ map toProtocolDef protocols
          , map toForeignDef foreignFns
          , map toTypeDef types
          ])
    where
    toProtocolDef (s, p) = ProtocolDefinition predefined (nameInUniverse s) p
    toTypeDef (s, t) = TypeDefinition predefined (nameInUniverse s) [] t
    toForeignDef (i, s) = ForeignDefinition predefined i s
