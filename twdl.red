Red [
  needs: 'view
]


if find system/options/args "-h" [
  print "twdl: downloads the latest empty TiddyWiki and saves in the current directory."
  print ""
  print "Usage:"
  print "  twdl [-e] [-p] [-o]"
  print ""
  print "OPTIONS:"
  print [tab "-e download current empty editions as `empty.html`."]
  print [tab "-p download prerelease empty edition as `empty-prerelease.html`."]
  print [tab "-o opens the downloaded wiki in browser."]
  print ""
  print {If no options are given, a the gui will open.}
  quit
]


;; Functions

fetch: func [edition] [
  name: get-filename edition
  url: get-url edition
  print ["Fetching" url]
  html: read url
  print ["Writing" name]
  write to-file name html
  if (open-file/data = true) [ open-in-browser name ]
]

write-html: func [file html] [
  write to-file file to-string html
]

fetch-html: func [url] [
  read to-url url
]


open-in-browser: func [filename] [
  OS: system/build/config/OS
  print ["Opening" filename]
  either [OS = 'Windows] [
    call rejoin [{start "" "} to-string filename {"}]
  ] [
    call rejoin [{xdg-open } to-string filename]
  ]
]

get-filename: func [edition] [
  selection: pick edition/data (edition/selected * 2)
  filename: last selection
  return filename
]

get-url: func [edition] [
  selection: pick edition/data (edition/selected * 2)
  url: to-url first selection
  return url
]

;; Main

args: system/options/args
opt-make-editions-file: take find args "--list-editions"
opt-empty: take find args "-e"
opt-prerelease: take find args "-p"
opt-open: take find args "-o"

if opt-empty [
  print ["Downloading empty.html"]
  write-html "empty.html" fetch-html https://tiddlywiki.com/empty.html
  if opt-open [open-in-browser "empty.html"]
  quit
]
if opt-prerelease [
  print ["Downloading prerelease empty.html"]
  write-html "empty-prerelease.html" fetch-html https://tiddlywiki.com/prerelease/empty.html
  if opt-open [open-in-browser "empty-prerelease.html"]
  quit
]


if opt-make-editions-file [
  print "creating editions file.."
  editions: [
    "Empty" "https://tiddlywiki.com/empty.html"
    "Full" "https://tiddlywiki.com"
    "Empty (Prerelease)" "https://tiddlywiki.com/prerelease/empty.html"
    "Full (Prerelease)" "https://tiddlywiki.com/prerelease"
  ]
  quit
]

; Currently available editions
editions-data: [
  "Empty"              ["https://tiddlywiki.com/empty.html" "empty.html"]
  "Full"               ["https://tiddlywiki.com" "tiddlywiki.html"]
  "Empty (Prerelease)" ["https://tiddlywiki.com/prerelease/empty.html" "empty-prerelease.html"]
  "Full (Prerelease)"  ["https://tiddlywiki.com/prerelease" {tiddlywiki-prerelease.html}]
]

;; GUI
view [
  on-key [
    ;probe event/key
    ; close on Esc key
    if event/key = #"^(esc)" [ quit ]
  ]
  title "New TiddlyWiki"
  text "Edition:"
  edition: drop-list data editions-data [ fn/text: get-filename edition ]
  return
  text "Save As:"
  fn: field 200
  return
  text  ""
  open-file: check "Open in browser after save?"
  return
  button "Fetch" focus [ fetch edition]
  button "Close" [ quit ]
  return
  do [
    edition/selected: 1
    fn/text: get-filename edition
  ]
]
