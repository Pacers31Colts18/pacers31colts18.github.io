function Check-GitTag {
    param ([string]$Id)
    git tag --list "microblog/$Id" | Where-Object { $_ }
}
