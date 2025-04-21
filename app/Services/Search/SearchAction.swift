import class DGis.SearchQuery
import struct DGis.MarkedUpText

enum SearchAction {
	case idle
	case search
	case searchQuery(SearchQuery, String, String)
	case setQueryText(String)
	case setSearchOptions(SearchOptions)
	case setError(String)
	case resetSuggestions
	case setSuggestResult(SuggestResultViewModel)
	case setSearchResult(SearchResultViewModel)
	case handleSuggest(SuggestViewModel)
	case applyObjectSuggest(SuggestViewModel)
	case navigate(SearchNavigation?)
    case setHistoryResult(SearchHistoryViewModel)
    case getHistory
    case clearHistory
	case handleSearchHistoryItem(SearchHistoryItemViewModel)
	case removeSearchHistoryItem(SearchHistoryItemViewModel)
}
