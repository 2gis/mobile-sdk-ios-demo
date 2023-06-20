struct SearchState {
	var queryText = ""
	var selection = SuggestViewModel?.none
	var errorMessage = ""
	var isErrorAlertShown = false
	var result = SearchResultViewModel.empty
	var suggestion = SuggestResultViewModel.empty
	var navigation: SearchNavigation?
	var searchOptions: SearchOptions?

	init() {
	}
}
