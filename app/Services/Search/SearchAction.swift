import class PlatformSDK.SearchQuery

enum SearchAction {
	case idle
	case search
	case searchQuery(SearchQuery)
	case setQueryText(String)
	case setError(String)
	case resetSuggestions
	case setSuggestResult(SuggestResultViewModel)
	case setSearchResult(SearchResultViewModel)
	case handleSuggest(SuggestViewModel)
	case applyObjectSuggest(SuggestViewModel)
	case navigate(SearchNavigation?)
}
