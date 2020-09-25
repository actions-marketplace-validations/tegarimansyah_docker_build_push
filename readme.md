# Docker Build then Push

Build your dockerfile then push to anywhere

## Implement

* Put `cicd.yml` in `.github/workflow` with this code:

```yaml
# This CI will run after publish a new release

name: Continous Integration and Continous Delivery

on:
  release:
    types: [published]
  
jobs:
  processing_docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and Test
        # Run your CI script before build docker image  
        run: make install && \
             make test && \
             make coverage && \
             make cleanup
      - name: Docker build then push
        uses: tegarimansyah/docker_build_push@master
        env:
            DOCKER_USER: ${{ secrets.DOCKER_USER }}
            PASSWORD: ${{ secrets.PASSWORD }}

            SEMVER: 0.1.0
            HOST: HOSTNAME.com
            ORG: PROJECTNAME
            APPNAME: APPNAME
            # if DEV is true then your image tag is as follow
            # 0.1.0-dev-c7bf9e21
            # where c7bf9e21 is your 8 char git hash
            # best for your staging server
            # else, the tag will be 0.1.0 ($SEMVER)
            DEV: false
```

* Adjust your environment. Please note that DOCKER_USER and PASSWORD is in your secret, don't write it in the file.
    * Your project secret in https://github.com/USERNAME/REPONAME/settings/secrets
    * Your organization secret in https://github.com/organizations/USERNAME/settings/secrets
* You can create two workflows if you want, 1 for staging `on push to master` (DEV: true) and 1 for production `on release` (DEV: false).

## Notes for GCR

* We can use [JSON Key file](https://cloud.google.com/container-registry/docs/advanced-authentication#json-key). Create one first.
* Use `_json_key` as DOCKER_USER in Repo / Org secret
* Put content of the JSON Key file to PASSWORD in Repo / Org secret
* Use https://asia.gcr.io for HOST (or other region)

## Don't Use Latest Tag For Your Production

Even though we will ship latest tag if `DEV` is `false`, it doesn't mean you can use it in production (or even in development because it will put you to confusion). Just use the specific tag and you are safe.

> “Latest” simply means “the last build/tag that ran without a specific tag/version specified”.
> 
> [Marc Campbell](https://www.google.com/search?q=what+is+latest+tag+in+docker&oq=what+is+latest+tag+&aqs=chrome.1.69i57j0.4911j1j4&sourceid=chrome&ie=UTF-8)