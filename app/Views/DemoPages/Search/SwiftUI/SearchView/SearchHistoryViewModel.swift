import CoreLocation 
import DGis

struct SearchHistoryViewModel {
    var items: [SearchHistoryItemViewModel]
    
    var isEmpty: Bool {
        self.items.isEmpty
    }
    
    init(
        items: [SearchHistoryItem]? = nil
    ) {
        self.items = items?.map { SearchHistoryItemViewModel(item: $0) } ?? []
    }
}

extension SearchHistoryViewModel {
    static let empty = SearchHistoryViewModel()
}
