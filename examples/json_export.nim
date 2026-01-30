## JSON Export/Import Example
##
## Demonstrates saving historical data to JSON and loading it back

import yfnim
import std/[times, os, json]

proc main() =
  let outputFile = "stock_data.json"
  
  echo "=== JSON Export Example ===\n"
  
  # Fetch data
  echo "Fetching AAPL data..."
  let now = getTime().toUnix()
  let weekAgo = now - (7 * 24 * 3600)
  
  let history = getHistory("AAPL", Int1d, weekAgo, now)
  echo "Retrieved ", history.len, " records\n"
  
  # Export to JSON
  echo "Exporting to ", outputFile, "..."
  let jsonNode = history.toJson()
  writeFile(outputFile, $jsonNode)
  
  let fileSize = getFileSize(outputFile)
  echo "Wrote ", fileSize, " bytes\n"
  
  # Import from JSON
  echo "Importing from ", outputFile, "..."
  let jsonContent = readFile(outputFile)
  let parsedJson = parseJson(jsonContent)
  let loaded = fromJson(parsedJson, History)
  
  echo "Loaded data:"
  echo "  Symbol: ", loaded.symbol
  echo "  Interval: ", loaded.interval
  echo "  Records: ", loaded.len
  
  # Verify data integrity
  echo "\nVerifying data integrity..."
  if loaded.len != history.len:
    echo "ERROR: Record count mismatch!"
    return
  
  var allMatch = true
  for i in 0..<loaded.len:
    let original = history.data[i]
    let imported = loaded.data[i]
    
    if original.time != imported.time or
       original.open != imported.open or
       original.high != imported.high or
       original.low != imported.low or
       original.close != imported.close or
       original.volume != imported.volume:
      echo "ERROR: Record ", i, " mismatch!"
      allMatch = false
      break
  
  if allMatch:
    echo "SUCCESS: All records match perfectly!"
  
  # Display first and last record
  echo "\nFirst record:"
  let first = loaded.data[0]
  echo "  Time: ", fromUnix(first.time).format("yyyy-MM-dd")
  echo "  Close: $", first.close
  
  echo "\nLast record:"
  let last = loaded.data[^1]
  echo "  Time: ", fromUnix(last.time).format("yyyy-MM-dd")
  echo "  Close: $", last.close
  
  # Cleanup
  echo "\nCleaning up..."
  removeFile(outputFile)
  echo "Done!"

when isMainModule:
  main()
