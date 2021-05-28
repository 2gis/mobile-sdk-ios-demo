import SwiftUI
import PlatformMapSDK

struct MarkedUpTextView: View {
	private let markup: MarkedUpText
	private let normalFont: Font
	private let matchFont: Font

	init(
		markup: MarkedUpText,
		normalFont: Font = Font.body,
		matchFont: Font = Font.body.weight(.medium)
	) {
		self.markup = markup
		self.normalFont = normalFont
		self.matchFont = matchFont
	}

	var body: some View {
		let parts = makeAlternatingParts(markup: self.markup)
		let texts = parts.flatMap { pair -> [Text] in
			let (normal, matched) = pair
			var texts: [Text] = []
			if !normal.isEmpty {
				texts.append(Text(normal).font(self.normalFont))
			}
			if !matched.isEmpty {
				texts.append(Text(matched).font(self.matchFont))
			}
			return texts
		}
		texts.reduce(into: Text(verbatim: ""), {
			acc, text in
			acc = acc + text
		})
	}
}

private func makeAlternatingParts(
	markup: MarkedUpText
) -> [(normal: Substring, matched: Substring)] {
	makeAlternatingParts(string: markup.text, matchedRanges: markup.matchedParts)
}

private func makeAlternatingParts(
	string: String,
	matchedRanges: [MarkedUpTextSpan]
) -> [(normal: Substring, matched: Substring)] {
	let utf8View = string.utf8
	var parts: [(Substring, Substring)] = []
	var partStartIndex = string.startIndex
	for range in matchedRanges {
		guard range.length > 0,
			let utf8LowerBound = utf8View.index(
				utf8View.startIndex,
				offsetBy: Int(range.offset),
				limitedBy: utf8View.endIndex
			),
			let lowerBound = utf8LowerBound.samePosition(in: string),
			let utf8UpperBound = utf8View.index(
				utf8LowerBound,
				offsetBy: Int(range.length),
				limitedBy: utf8View.endIndex
			),
			let upperBound = utf8UpperBound.samePosition(in: string)
		else {
			continue
		}
		let unmatchedRange = partStartIndex ..< lowerBound
		let matchedRange = lowerBound ..< upperBound
		let pair = (normal: string[unmatchedRange], matched: string[matchedRange])
		parts.append(pair)
		partStartIndex = upperBound
	}
	// Add the last one.
	let lastNormalRange = partStartIndex..<string.endIndex
	if !lastNormalRange.isEmpty {
		parts.append((normal: string[lastNormalRange], matched: string[string.endIndex...]))
	}
	return parts
}
