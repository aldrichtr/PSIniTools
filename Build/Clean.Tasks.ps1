
# synopsis: remove files and directories in artifacts
task remove_artifact_files {
    Remove-Item -Path "$($Path.Artifact)\*" -Recurse -ErrorAction SilentlyContinue
}

# synopsis: remove files and directories in staging
task remove_staging_files {
    Remove-Item "$($Path.Staging)\*" -Recurse -ErrorAction SilentlyContinue
}
