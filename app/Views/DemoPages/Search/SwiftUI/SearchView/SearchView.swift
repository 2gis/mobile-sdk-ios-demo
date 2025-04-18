import SwiftUI
import DGis

struct SearchView: View {
	typealias Color = SwiftUI.Color
	typealias State = SwiftUI.State
	
	private enum Constants {
		enum SearchTextField {
			static let iconSize: CGSize = .init(width: 20, height: 20)
			static let horizontalPadding: CGFloat = 5
			static let minHeight: CGFloat = 44
			static let cornerRadius: CGFloat = 8
			static let strokeWidth: CGFloat = 1
			static let strokeColor: Color = .gray
		}
		static let padding: CGFloat = 8
	}
	
	@ObservedObject var store: SearchStore
	@State private var isFilterShown: Bool = false
	let logger: ILogger
	let directoryViewsFactory: IDirectoryViewsFactory

	var body: some View {
		Group {
			VStack(spacing: Constants.padding) {
				HStack {
					self.searchTextField
					self.filterButton
					self.speechRecButton
				}
				.padding(.horizontal, Constants.SearchTextField.horizontalPadding)
				.frame(minHeight: Constants.SearchTextField.minHeight)
				.background(
					RoundedRectangle(cornerRadius: Constants.SearchTextField.cornerRadius)
						.strokeBorder(Constants.SearchTextField.strokeColor, lineWidth: Constants.SearchTextField.strokeWidth)
				)
				ScrollView(.horizontal) {
					HStack {
						ForEach(SearchRubric.allCases) { rubric in
							self.rubricButton(rubric: rubric)
						}
					}
					.frame(minHeight: Constants.SearchTextField.minHeight)
				}


                if !self.store.state.suggestion.isEmpty {
                    SuggestResultView(
                        dispatcher: self.store.dispatcher,
                        viewModel: self.store.state.suggestion,
                        navigation: self.store.bind(\.navigation) { .navigate($0) }
                    )
                    Divider()
                } else if !self.store.state.result.isEmpty {
                    SearchResultView(
                        viewModel: self.store.state.result,
                        navigation: self.store.bind(\.navigation) { .navigate($0) }
                    )
                } else if !self.store.state.history.isEmpty {
                    Button("clear") {
                        self.store.dispatch(.clearHistory)
                    }
                    SearchHistoryView(
                        dispatcher: self.store.dispatcher,
                        viewModel: self.store.state.history,
                        navigation: self.store.bind(\.navigation) { .navigate($0) }
                    )
                } else {
                    Spacer()
                }
            }
			.background(Color(UIColor.systemBackground))
		}
		.overlay(self.voiceAssistantOverlay)
		.sheet(isPresented: self.$isFilterShown) {
			SearchOptionsView(
				searchOptions: self.store.state.searchOptions ?? SearchOptions(),
				isPresented: self.$isFilterShown
			) { options in
				self.store.dispatch(.setSearchOptions(options))
			}
		}
		.navigationBarTitle("Directory Search", displayMode: .inline)
		.alert(isPresented: self.$store.state.isErrorAlertShown) {
			Alert(title: Text(self.store.state.errorMessage))
		}
	}
	
	private var searchTextField: some View {
		TextField(
			"Enter...",
			text: self.store.bind(\.queryText) { .setQueryText($0) },
			onEditingChanged: { (isFocused) in
				if isFocused {
					if self.store.state.queryText.isEmpty {
						self.store.dispatch(.getHistory)
					}
				}
			},
			onCommit: { self.store.dispatch(.search) }
		)
	}
	
	private var filterButton: some View {
		Button (
			action: { self.isFilterShown = true },
			label: {
				Image(systemName: "slider.horizontal.3")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(
						width: Constants.SearchTextField.iconSize.width,
						height: Constants.SearchTextField.iconSize.height
					)
			}
		)
	}
	
	private var speechRecButton: some View {
		Button (
			action: {
				self.hideKeyboard()
				self.voiceAssistantOverlay.startRecognition()
			},
			label: {
				Image(systemName: "mic")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(
						width: Constants.SearchTextField.iconSize.width,
						height: Constants.SearchTextField.iconSize.height
					)
			}
		)
	}
		

	private func rubricButton(rubric: SearchRubric) -> some View {
		Text(rubric.name)
		.padding()
		.background(
			ZStack {
				RoundedRectangle(cornerRadius: 8)
					.fill(self.store.state.rubricIds.firstIndex(of: rubric.value) != nil ? .gray : Color(UIColor.systemBackground))
				RoundedRectangle(cornerRadius: 8)
					.strokeBorder(Color.gray, lineWidth: 1)
			}
		)
		.onTapGesture {
			if let index = self.store.state.rubricIds.firstIndex(of: rubric.value) {
				self.store.state.rubricIds.remove(at: index)
			} else {
				self.store.state.rubricIds.append(rubric.value)
			}
			self.store.dispatch(.search)
		}
	}

	private var voiceAssistantOverlay: VoiceAssistantView {
		self.directoryViewsFactory.makeVoiceAssistantView(speechService: nil)
			.permissionDeniedCallback {
				self.logger.error("Failed to get voice assistant permissions.")
			}
			.recognitionCompleteCallback(callback: { result in
				if case .finished(let text) = result {
					if let text {
						self.store.state.queryText = text
						self.store.dispatch(.search)
					}
				}
			})
	}
}
