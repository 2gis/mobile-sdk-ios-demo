enum SearchNavigation: Hashable {
	case idle
	case openSuggest(SuggestViewModel.ID)
	case openSearchResultItem(SearchResultItemViewModel.ID)
    case openDirectoryObject(DirectoryObjectViewModel.ID)
}
