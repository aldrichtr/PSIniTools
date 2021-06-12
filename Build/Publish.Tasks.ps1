
# A task for publishing the artifacts to gitlab package registry
task publish_to_gitlab_feed {
    if ( -not ( Get-Childitem Env:\CI_SERVER_URL -ErrorAction SilentlyContinue ) )
    {
        Write-Build Red '- Build is being run local and will not be published to gitlab feed.'
        return
    }
    # nuget.exe is provided by the PowerShell Docker Container. See the following repo for more details.
    # https://git.imefdm.usmc.mil/gitlab-instance-75fba46f/gitlab-build-containers
    [void]( & c:\PsRepo\nuget.exe sources add -Source "$env:CI_SERVER_URL/api/v4/projects/$env:CI_PROJECT_ID/packages/nuget/index.json" -Name gitlab -Username gitlab-ci-token -Password $env:CI_JOB_TOKEN -StorePasswordInClearText )

    & c:\PsRepo\nuget.exe push "$( $Path.Artifact )\*.nupkg" -Source gitlab
}