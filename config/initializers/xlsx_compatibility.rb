require "zip"

# These small XLSX exports use standard ZIP. Rubyzip's ZIP64 extraction headers
# can make LibreOffice reject the workbook even when caxlsx suppresses ZIP64 fields.
Zip.write_zip64_support = false
