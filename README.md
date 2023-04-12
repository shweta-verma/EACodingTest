**Overview:** 
This Project is using MVVM arctitecture to solve the given problem. It displays the the list of music festival data in a particular manner: at the top level, it is shows the band record label, below that it shows list out all bands under their management, and below that it  displays which festivals they've attended, if any. All entries are sorted alphabetically.

The data is coming from the API https://eacp.energyaustralia.com.au/codingtest/api-docs

**ViewControllers**

RecordsViewController - Consists of a tableView to show data

**ViewModels**

RecordsViewModel - Call the API to load data, having business logic to convert data and provides to its controller

**Views**

Main.storyboard - Consists of viewcontroller

**DataModel**

Festival - DataModel for the Festival and Band Data model


**Other**

NetworkManager - To call the APIs

**Mocks and Unit Tests**



MockFestivals - To mock Festivals response

MockNetworkManager - Mocking API call

RecordsViewModelTests - To test respective ViewModel


**Assumptions:**

1 - A band is associated with only one recordLabel

2 - A band object will always be present in Festival object(if any) in the API response 

3 - If there is any recordLabel blank(""). It will be shown at the top of recordLabel list as a blank tableView section header consiting of associated bands and their attended festival list.
4 - If a band festival is blank(""). There will be blank tableview row under band list.
