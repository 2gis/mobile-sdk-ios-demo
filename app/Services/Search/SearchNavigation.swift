enum SearchNavigation: Hashable {
	case idle
	case openSuggest(SuggestViewModel.ID)
	case openDirectoryObject(DirectoryObjectViewModel.ID)
}
