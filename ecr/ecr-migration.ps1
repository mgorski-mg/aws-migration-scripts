param(
    [Parameter(Mandatory = $True)]
    [string]$SourceRepoName,

    [Parameter(Mandatory = $True)]
    [string]$TargetRepoName
)

$accountId = aws sts get-caller-identity | ConvertFrom-Json | Select-Object -ExpandProperty "Account"
$loginUrl = "$accountId.dkr.ecr.eu-west-1.amazonaws.com"

aws ecr get-login-password | docker login --username AWS --password-stdin $loginUrl

$images = aws ecr list-images --repository-name $SourceRepoName --filter 'tagStatus=TAGGED' | ConvertFrom-Json | Select-Object -ExpandProperty "imageIds"

$sourceRepoUri = "$loginUrl/$SourceRepoName"
$targetRepoUri = "$loginUrl/$TargetRepoName"

foreach ($image in $images)
{
    $tag = $image.imageTag

    docker pull "${sourceRepoUri}:$tag"
    docker tag "${sourceRepoUri}:$tag" "${targetRepoUri}:$tag"
    docker push "${targetRepoUri}:$tag"
}