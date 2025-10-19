import Foundation

@main
struct TestRunner {
    static func main() async {
        await runAPITests()
    }
}

func runAPITests() async {
    let apiService = APIService()

    print("Testing API services...")

    // Test fetchCryptoPriceCryptoCompare
    do {
        if let price = try await apiService.fetchCryptoPriceCryptoCompare(symbol: "BTC", currency: "usd") {
            print("✅ Bitcoin price (CryptoCompare): \(price) USD")
        } else {
            print("❌ Failed to fetch Bitcoin price (CryptoCompare).")
        }
    } catch {
        print("❌ Error fetching Bitcoin price (CryptoCompare): \(error)")
    }

    // Test fetchStockOrETFPrice
    do {
        if let price = try await apiService.fetchStockOrETFPrice(isin: "IE00B4L5Y983", currency: "USD") {
            print("✅ iShares Core S&P 500 UCITS ETF price: \(price) USD")
        } else {
            print("❌ Failed to fetch stock/ETF price.")
        }
    } catch {
        print("❌ Error fetching stock/ETF price: \(error)")
    }

    // Test fetchRawMaterialPrice
    do {
        if let price = try await apiService.fetchRawMaterialPrice(material: "XAU", currency: "USD") {
            print("✅ Gold price: \(price) USD")
        } else {
            print("❌ Failed to fetch Gold price.")
        }
    } catch {
        print("❌ Error fetching Gold price: \(error)")
    }
}
