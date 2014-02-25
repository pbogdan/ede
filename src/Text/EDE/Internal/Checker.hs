-- Module      : Text.EDE.Internal.Checker
-- Copyright   : (c) 2013-2014 Brendan Hay <brendan.g.hay@gmail.com>
-- License     : This Source Code Form is subject to the terms of
--               the Mozilla Public License, v. 2.0.
--               A copy of the MPL can be found in the LICENSE file or
--               you can obtain it at http://mozilla.org/MPL/2.0/.
-- Maintainer  : Brendan Hay <brendan.g.hay@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)

module Text.EDE.Internal.Checker where

import Control.Monad
import Text.EDE.Internal.Checker.Class
import Text.EDE.Internal.Checker.Monad
import Text.EDE.Internal.Types

tiExp :: ClassEnv -> [Assump] -> Exp -> Check ([Pred], Type)
tiExp ce as (EVar i) = do
    sc         <- find i as
    (ps :=> t) <- freshInst sc
    return (ps, t)
tiExp ce as (ELit l) = do
    (ps, t)    <- tiLit l
    return (ps, t)
tiExp ce as (EApp e f) = do
    (ps, te)   <- tiExp ce as e
    (qs, tf)   <- tiExp ce as f
    t          <- freshTVar Star
    unify (tf --> t) te
    return (ps++qs, t)
-- tiExp ce as (ELet bg e) = do
--     (ps, as')  <- tiBindGroup ce as bg
--     (qs, t)    <- tiExp ce (as' ++ as) e
--     return (ps ++ qs, t)

tiLit :: Lit -> Check ([Pred], Type)
tiLit (LInt  _) = do
    v <- freshTVar Star
    return ([IsIn "Num" v], v)
tiLit (LChar _) = return ([], tChar)
tiLit (LStr  _) = return ([], tString)
tiLit (LBool _) = return ([], tBool)