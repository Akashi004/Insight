import Foundation

protocol DataLoading {
    func loadBankingData() throws -> BankingData
}

enum DataLoadingError: Error, LocalizedError {
    case missingFile(String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .missingFile(let file):
            return "Missing JSON file: \(file)"
        case .decodingFailed:
            return "Unable to decode JSON data."
        }
    }
}

final class JSONDataService: DataLoading {
    private let fileName: String
    private let bundle: Bundle

    init(fileName: String = "banking_data", bundle: Bundle = .main) {
        self.fileName = fileName
        self.bundle = bundle
    }

    func loadBankingData() throws -> BankingData {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw DataLoadingError.missingFile(fileName)
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(BankingData.self, from: data)
        } catch {
            throw DataLoadingError.decodingFailed
        }
    }
}
