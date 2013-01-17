--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Control.Applicative ((<$>))
import           Data.List           (sortBy)
import           Data.Monoid
import           Data.Ord            (comparing)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "static/css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "static/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "entries/**" . version "html" $ do
      route $ gsubRoute "entries/" (const "") `composeRoutes`
              setExtension "html"
      compile $ pandocCompiler
        >>= loadAndApplyTemplate "templates/entry.html"   entryCtx
        >>= loadAndApplyTemplate "templates/default.html" entryCtx
        >>= relativizeUrls

    create ["entries.html"] $ do
        route idRoute
        compile $ do
            let archiveCtx = mconcat
                             [ field "entries" (const $ entryList alphabetical)
                             , constField "title" "All entries"
                             , defaultContext
                             ]
            makeItem ""
                >>= loadAndApplyTemplate "templates/entries.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
entryCtx :: Context String
entryCtx = mconcat
  [ dateField "updatedOn" "%B %e, %Y"
  , defaultContext
  ]

--------------------------------------------------------------------------------
entryList :: ([Item String] -> [Item String]) -> Compiler String
entryList sortFilter = do
    entries <- sortFilter <$> loadAll "entries/**"
    itemTpl <- loadBody "templates/entries-item.html"
    list    <- applyTemplateList itemTpl entryCtx entries
    return list

alphabetical :: [Item a] -> [Item a]
alphabetical = sortBy . comparing $ toFilePath . itemIdentifier
