import Foundation

func main() {
    guard let path = CommandLine.arguments.last else {
        print("pass the path argument to the call")
        return
    }
    guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
        print("failed to get directory content")
        return
    }

    print("import CoreGraphics")
    print("")

    var result: [StickerData] = []
    for file in contents.sorted() where !file.hasSuffix("+mask.imageset") {
        let filename = file.dropLast(9)
        let array = filename
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: "+").map { String($0) }
        guard array.count == 8 else {
            continue
        }
        guard let packNumber = Int(array[2]),
            let coordX = Int(array[3]),
            let coordY = Int(array[4]),
            let deltaX = Int(array[5]),
            let deltaY = Int(array[6]),
            let angle = Int(array[7]) else {
            print("failed to get data for sticker \(filename)")
            continue
        }
        result += [
            StickerData(
                categoryName: array[0],
                packName: array[1],
                packNumber: packNumber,
                filename: String(filename),
                coordX: coordX,
                coordY: coordY,
                deltaX: deltaX,
                deltaY: deltaY,
                angle: angle
            ),
        ]
    }
    logGroupedResult(
        grouped: Dictionary(
            grouping: result,
            by: { $0.categoryName }
        )
        .mapValues { value in
            Dictionary(grouping: value, by: { $0.packName })
        }
    )
}

private func logGroupedResult(grouped: [String: [String: [StickerData]]]) {
    printMessage("extension StickerPackCategory {")
    var level = 1
    printMessage(with: level, "static var all: [StickerPackCategory] {")
    level += 1
    printMessage(with: level, "return [")
    level += 1
    for (category, packs) in grouped.sorted(by: { $0.key < $1.key }) {
        logCategory(category, packs: packs, level: &level)
    }
    level -= 1
    printMessage(with: level, "]")
    level -= 1
    printMessage(with: level, "}")
    level -= 1
    printMessage("}")
}

private func logCategory(_ category: String, packs: [String: [StickerData]], level: inout Int) {
    printMessage(with: level, " StickerPackCategory(")
    level += 1
    printMessage(with: level, "name: \"\(category)\",")
    printMessage(with: level, "packs: [")
    level += 1
    for (pack, stickers) in packs.sorted(by: { $0.key < $1.key }) {
        logPack(pack, stickers: stickers, level: &level)
    }
    level -= 1
    printMessage(with: level, "]")
    level -= 1
    printMessage(with: level, "),")
}

private func logPack(_ pack: String, stickers: [StickerData], level: inout Int) {
    printMessage(with: level, "StickerPack(")
    level += 1
    printMessage(with: level, "name: \"\(pack)\",")
    printMessage(with: level, "realStickers: [")
    level += 1

    for sticker in stickers.sorted(by: { $0.filename < $1.filename }) {
        logSticker(sticker, level: &level)
    }

    level -= 1
    printMessage(with: level, "]")
    level -= 1
    printMessage(with: level, "),")
}

private func logSticker(_ sticker: StickerData, level: inout Int) {
    printMessage(with: level, "Sticker(")
    level += 1
    printMessage(with: level, "imageName: \"\(sticker.filename)\",")
    printMessage(with: level, "number: \(sticker.packNumber),")
    printMessage(with: level, "maskCenter: CGPoint(x: \(sticker.coordX), y: \(sticker.coordY)),")
    printMessage(
        with: level,
        "maskInnerOffset: CGPoint(x: \(sticker.deltaX - sticker.coordX), y: \(sticker.deltaY - sticker.coordY)),"
    )
    printMessage(with: level, "angle: \(sticker.angle)")
    level -= 1
    printMessage(with: level, "),")
}

private func printMessage(with offset: Int = 0, _ message: String) {
    let prefix = Array(repeating: " ", count: offset * 4).joined()
    print("\(prefix)\(message)")
}

struct StickerData: Hashable {
    var categoryName: String
    var packName: String
    var packNumber: Int
    var filename: String
    var coordX: Int
    var coordY: Int
    var deltaX: Int
    var deltaY: Int
    var angle: Int

    var mask: String {
        return filename + "_mask"
    }
}

main()
