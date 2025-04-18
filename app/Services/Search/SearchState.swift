import DGis

struct SearchState {
	var queryText = ""
	var selection = SuggestViewModel?.none
	var errorMessage = ""
	var isErrorAlertShown = false
	var result = SearchResultViewModel.empty
	var suggestion = SuggestResultViewModel.empty
    var history = SearchHistoryViewModel.empty
	var navigation: SearchNavigation?
	var searchOptions: SearchOptions?
	var rubricIds: [RubricId] = []

	init() { }
}
