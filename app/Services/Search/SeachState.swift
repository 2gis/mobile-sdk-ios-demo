struct SearchState {
	var queryText = ""
	var selection = SuggestViewModel?.none
	var errorMessage = ""
	var result = SearchResultViewModel.empty
	var suggestion = SuggestResultViewModel.empty
	var navigation: SearchNavigation?

	init() {
	}
}
