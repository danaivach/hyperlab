# hyperlab
A demo scenario for the Web Conference 2020, showcasing a dynamic WoT environment where (partial) plans are missing or need to be assembled by the agents.

# Setup
* Install gradle
* Run `git submodule init` and `git submodule update` to retrieve the latest version of the dependent repositories
* In the yggrasil folder, run `./gradlew` to build the jar file for yggrasil
* In the wot-search folder, run `./gradlew` to build the jar file for the hypermedia search engine
* In the hyperlab_demo_gui folder, run `npm install` to install the requirements for the ui-backend, i.e. node and express.js
* In the hyperlab_demo_gui/ui folder, run `npm install` to install the requirements for the react ui
* In the hyperlab_demo_gui/ui folder run `npm run build` to create a production build of the ui

## Run it
To run the system, the following steps are necessary:
* set up a hypermedia environment using [Yggdrasil](https://github.com/Interactions-HSG/yggdrasil/tree/hyperlab_demo) on feature/hyperlab_demo branch on port 8080 (default) by executing `java -jar yggdrasil/build/libs/yggdrasil-0.0-SNAPSHOT-fat.jar -conf yggdrasil/src/main/conf/config1.json`
* set up a [WoT search engine](https://github.com/Interactions-HSG/wot-search) on port 9090 (default) by executing `java -jar wot-search/build/libs/crawler-0.0-SNAPSHOT-fat.jar -conf wot-search/src/main/conf/config1.json`
* Create the workspace and the artifacts using our [Postman collection](https://www.getpostman.com/collections/f6a89ddd4f3b5900a54f) or the scripts located in the scripts folder.
* run the JaCaMo MAS environment in this repo by executing `gradle` in your console from the root directory of the repo
* run the ui-backend which serves the demo UI on http://localhost:5000 by executing `npm start` in the hyperlab_demo_gui folder
