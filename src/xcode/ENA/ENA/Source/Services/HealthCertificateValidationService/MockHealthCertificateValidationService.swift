////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

struct MockHealthCertificateValidationService: HealthCertificateValidationProviding {

	var onboardedCountriesResult: Result<[Country], ValidationOnboardedCountriesError> = .success(
		[
			Country(countryCode: "DE"),
			Country(countryCode: "IT"),
			Country(countryCode: "ES")
		].compactMap { $0 }
	)

	var validationResult: Result<HealthCertificateValidationReport, HealthCertificateValidationError> = .success(.validationPassed)

	func onboardedCountries(
		completion: @escaping (Result<[Country], ValidationOnboardedCountriesError>) -> Void
	) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			completion(onboardedCountriesResult)
		}
	}
	
	func validate(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			completion(validationResult)
		}
	}

}