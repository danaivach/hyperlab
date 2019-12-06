# hyperlab
A demo scenario for the Web Conference 2020, showcasing a dynamic WoT environment where (partial) plans are missing or need to be assembled by the agents.

# Setup
* install gradle
* run 'git submodule init' and 'git submodule update' to retrieve the latest version of the wot-td-parser repository

## Run it
To run the system, the following steps are necessary:
* set up a hypermedia environment using [Yggdrasil](https://github.com/Interactions-HSG/yggdrasil/tree/hyperlab_demo) on feature/hyperlab_demo branch on port 8080 (default) and the requests from our [Postman collection](https://www.getpostman.com/collections/f6a89ddd4f3b5900a54f).

* set up a [WoT search engine](https://github.com/Interactions-HSG/wot-search) on port 9090 (default)

* run the JaCaMo MAS environment in this repo by executing 'gradle' in your console from the root directory of the repo
