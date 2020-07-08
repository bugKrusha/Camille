extension Array where Element: Hashable {
    func removeDuplicates() -> Array {
        var result = Array()
        var seen: Set<Element> = []

        for item in self {
            guard seen.insert(item).inserted else { continue }

            result.append(item)
        }

        return result
    }
}
