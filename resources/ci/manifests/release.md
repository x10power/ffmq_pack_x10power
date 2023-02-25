# Checklist for Release

* Checkout `stable`

* Run tests locally
  * Using python directly
    * `py -m pip install -r "./resources/app/meta/manifests/pip_requirements.txt"`
    * `py -m resources.tests.items`
    * `py -m resources.tests.functions`
    * `py -m resources.tests.locations`
    * `py -m resources.tests.asserts.validate`
  * Using bash
    * `./resources/ci/common/sh/ci.sh`
* Update `./resources/app/meta/manifests/app_version.txt`
  * Run ID will be appended to this value
* Update `./RELEASENOTES.md`
  * This will become the body of the Release entry

* *Links*
  * *[pip requirements](https://github.com/x10power/ffmq-rando-tracker/blob/stable/resources/app/meta/manifests/pip_requirements.txt)*
  * *[bash script](https://github.com/x10power/ffmq-rando-tracker/blob/stable/resources/ci/common/sh/ci.sh)*
  * *[AppVersion](https://github.com/x10power/ffmq-rando-tracker/blob/stable/resources/app/meta/manifests/app_version.txt)*
  * *[ReleaseNotes](https://github.com/x10power/ffmq-rando-tracker/blob/stable/RELEASENOTES.md)*

* Push to `stable`
  * Watch **[GitHub Actions](https://github.com/x10power/ffmq-rando-tracker/actions)** to verify that it passes the online environment

* If it passes:
  * Merge into `main`
    * This will run magic to:
      * Create a Release
      * Package the archive so that it can be dropped in to the user's EmoTracker `packs` folder
      * Fire off the update to the EmoTracker Package Repository

  * Verify archive asset uploaded to latest **[Release](http://github.com/x10power/ffmq-rando-tracker/releases)**
  * Verify version number properly updated in **[EmoTracker Package Repository](https://github.com/x10power/x10power-packs/blob/gh-pages/repository.json)**
  * Verify Update Available in EmoTracker's Package Manager
